task CompareDataMatrix {
  File base_datafile
  File updated_datafile
  File metadata_file
  String output_name
  String src_dir
  
  command {
    set -e
    mkdir ${output_name}
    gsutil cp ${src_dir}/Compare_data_matrix.R ./
    gsutil cp ${src_dir}/analysis_functions.R ./
    cat Compare_data_matrix.R
    Rscript Compare_data_matrix.R \
      --matrix1 ${base_datafile} \
      --matrix2 ${updated_datafile} \
      --metadata_file ${metadata_file} \
      --output_prefix ${output_name}/${output_name} 
    tar -zcvf ${output_name}.tar.gz ${output_name}
  }
  output {
    File combined_results = "${output_name}.tar.gz"
  }
  runtime {
    docker:"gcr.io/broad-dsde-mint-dev/analysis-tools:0.0.6"
    memory:"7.5 GB"
    disks: "local-disk 50 HDD"
    preemptible: 5
  }
}

workflow RunDataMatrixComparison {
  String scripts_dir
  String base_datafile
  String updated_datafile
  String output_name
  String metadata_file

  call CompareDataMatrix {
    input:
      base_datafile = base_datafile,
      updated_datafile = updated_datafile,
      output_name = output_name,
      metadata_file = metadata_file,
      src_dir = scripts_dir,
  }
}
