version 1.0

workflow joint_calling_cpu {
    input {
        String output_vcf_basename
        Array[File] single_sample_gvcfs
        Array[File] single_sample_gvcf_indices

        String? interval_name
        Int scatter_count
        File inputRefTarball

        String docker_img_glnexus = 'cr-cn-beijing.ivolces.com/popgenomics/glnexus:latest'
        String docker_img_gatk4 = 'cr-cn-beijing.ivolces.com/popgenomics/gatk:4.3.0.0'
    
    }

    call split_intervals {
        input:
            scatter_count = scatter_count,
            inputRefTarball = inputRefTarball,
            interval_name = interval_name,
            docker_img = docker_img_gatk4
    }

    scatter (bed_file in split_intervals.scatter_bed_file) {
        call glnexus {
            input:
                output_vcf_basename = output_vcf_basename,
                single_sample_gvcfs = single_sample_gvcfs,
                single_sample_gvcf_indices = single_sample_gvcf_indices,
                bed_file = bed_file,
                docker_img = docker_img_glnexus
        }
    }
    String ref_name = basename(basename(basename(inputRefTarball, ".tar"), ".gz"), ".fa")

    call merge_vcfs {
        input:
            output_vcf_basename = output_vcf_basename,
            output_vcf_sufix = ref_name,
            vcfs = glnexus.output_vcf,
            docker_img = docker_img_gatk4
    }

    output {
        Array[File] joint_vcf = merge_vcfs.vcf_output
    }
}

task split_intervals {
    input {
        Int scatter_count
        File inputRefTarball
        String? interval_name

        Int cpu = 1
        Int memory = 2
        Int disk_size_gb = 40
        String docker_img
    }
    String ref = basename(inputRefTarball, ".tar")
    String ref_name = basename(basename(ref, ".gz"), ".fa")

    command <<<
        set -euo pipefail
        tar -xf ~{inputRefTarball}


        gatk SplitIntervals \
            -R ~{ref} \
            --scatter-count ~{scatter_count} \
            -O intervals \
            ~{if defined(interval_name) then "-L ~{interval_name}" else ""}
        
        ls intervals/* | while read interval_file; do
            interval_num=$(basename -scattered.interval_list)
            gatk IntervalListToBed \
                -I ${interval_file} \
                -O ~{ref_name}.~{if defined(interval_name) then "~{interval_name}." else ""}${interval_num}.bed
        done
    >>>

    runtime {
        cpu: "~{cpu}"
        memory: '~{memory} GB'
        disk: "~{disk_size_gb} GB"
        docker: docker_img
    }

    output {
        Array[File] scatter_interval_list_file = glob("intervals/*.interval_list$")
        Array[File] scatter_bed_file = glob("*.bed$")
    }
}

task glnexus {
    input {
        String output_vcf_basename
        Array[File] single_sample_gvcfs
        Array[File] single_sample_gvcf_indices

        File bed_file

        Int cpu = 64
        Int memory = 128
        Int disk_size_gb = 0
        String docker_img
    }

    String bed_prefix = basename(bed_file, ".bed")
    String out_prefix = output_vcf_basename + "." + bed_prefix
    String out_bcf = out_prefix + ".bcf"
    String out_vcf = out_prefix + ".vcf.gz"
    String out_vcf_tbi = out_vcf + ".tbi"
    Int auto_diskGB = if disk_size_gb == 0 then ceil(size(single_sample_gvcfs, "GB") * 2.5) + 40 else disk_size_gb

    
    command <<<
        set -euo pipefail

        glnexus_cli \
            --config gatk \
            --bed ~{bed_file} \
            --list ~{write_lines(single_sample_gvcfs)} > ~{out_bcf}
        
        bcftools index ~{out_bcf}

        bcftools view ~{out_bcf} -Oz -o ~{out_vcf}
        bcftools index -t ~{out_vcf}

    >>>

    runtime {
        cpu: "~{cpu}"
        memory: '~{memory}G'
        disk: "~{auto_diskGB} GB"
        docker: docker_img
    }

    output {
        File output_vcf = out_vcf
        File output_vcf_tbi = out_vcf_tbi
    }
}

task merge_vcfs {

    input {
        String output_vcf_basename
        String output_vcf_sufix
        Array[File] vcfs
        
        # Resource
        Int cpu = 2
        Int memory = 16
        Int disk_size_gb = 0
        
        # docker 
        String docker_img    
    }

    Int auto_diskGB = if disk_size_gb == 0 then ceil(2 * size(vcfs, "GB")) + 40 else disk_size_gb

    String vcf = output_vcf_basename + "." + output_vcf_sufix + ".vcf.gz"
    String vcf_idx = vcf + ".tbi"

    command <<<
        gatk MergeVcfs \
            -I ~{sep=" -I " vcfs} \
            -O ~{vcf}
    >>>

    runtime {
        cpu: "~{cpu}"
        memory: '~{memory} GB'
        disk: "~{auto_diskGB} GB"
        docker: docker_img
    }

    output {
        Array[File] vcf_output = [vcf, vcf_idx]
    }
}
