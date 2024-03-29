[![Tests](https://github.com/BCCDC-PHL/downsample-reads/actions/workflows/tests.yml/badge.svg)](https://github.com/BCCDC-PHL/downsample-reads/actions/workflows/tests.yml)

# downsample-reads

```mermaid
flowchart TD
  reads --> fastp_input(fastp_input)
  fastp_input --> downsample("downsample (rasusa)")
  downsample --> fastp_output(fastp_output)
  downsample --> downsampled_reads
  fastp_output --> downsampling_summary[downsampling_summary.csv]
```

## Usage

```
nextflow run BCCDC-PHL/downsample-reads \
  -profile conda \
  --cache ~/.conda/envs \
  --coverage 30 \
  --fastq_input </path/to/fastqs> \
  --outdir </path/to/output_dir>
```

```
nextflow run BCCDC-PHL/downsample-reads \
  -profile conda \
  --cache ~/.conda/envs \
  --fastq_input </path/to/fastqs> \
  --outdir </path/to/output_dir>
```

The default genome size is 5 megabases (`5m`). To specify another genome size, use the `--genome_size` flag:

```
nextflow run BCCDC-PHL/downsample-reads \
  -profile conda \
  --cache ~/.conda/envs \
  --genome_size '30k' \
  --coverage 100 \
  --fastq_input </path/to/fastqs> \
  --outdir </path/to/output_dir>
```

### SampleSheet Input

If sample-specific downsampling parameters are needed, they can be provided via samplesheet input.

Prepare a `samplesheet.csv` file with the following fields:

```
ID
R1
R2
GENOME_SIZE
COVERAGE
```

...for example:

```csv
ID,R1,R2,GENOME_SIZE,COVERAGE
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz,5.0m,100
sample-02,/path/to/sample-02_R1.fastq.gz,/path/to/sample-02_R2.fastq.gz,3.0m,100
sample-03,/path/to/sample-03_R1.fastq.gz,/path/to/sample-03_R2.fastq.gz,3.0m,50
```

...then run the pipeline using the `--samplesheet_input` flag as follows:

```
nextflow run BCCDC-PHL/downsample-reads \
  -profile conda \
  --cache ~/.conda/envs \
  --samplesheet_input samplesheet.csv \
  --outdir </path/to/output_dir>
```

Note that you can include multiple entries for each sample:

```csv
ID,R1,R2,GENOME_SIZE,COVERAGE
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz,5.0m,25
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz,5.0m,50
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz,5.0m,100
sample-02,/path/to/sample-02_R1.fastq.gz,/path/to/sample-02_R2.fastq.gz,3.0m,10
sample-02,/path/to/sample-02_R1.fastq.gz,/path/to/sample-02_R2.fastq.gz,3.0m,100
sample-03,/path/to/sample-03_R1.fastq.gz,/path/to/sample-03_R2.fastq.gz,3.0m,50
sample-03,/path/to/sample-03_R1.fastq.gz,/path/to/sample-03_R2.fastq.gz,3.0m,100
sample-03,/path/to/sample-03_R1.fastq.gz,/path/to/sample-03_R2.fastq.gz,3.0m,200
```

### Collect Outputs

By default, a separate 'downsampling summary' csv file will be created for each sample, for
each depth of coverage that is specified. If the `--collect_outputs` flag is supplied then
an additional file will be included in the output directory that includes downsampling summary
info for all samples.

By default, the collected downsampling summary file will be named `collected_downsampling_summary.csv`.
Use the `--collected_outputs_prefix` flag to replace `collected` with some other prefix.

For example:

```
nextflow run BCCDC-PHL/downsample-reads \
  -profile conda \
  --cache ~/.conda/envs \
  --samplesheet_input samplesheet.csv \
  --collect_outputs \
  --outdir </path/to/output_dir>
```

...will add the file `collected_downsampling_summary.csv` to the outdir. And:

```
nextflow run BCCDC-PHL/downsample-reads \
  -profile conda \
  --cache ~/.conda/envs \
  --samplesheet_input samplesheet.csv \
  --collect_outputs \
  --collected_outputs_prefix test \
  --outdir </path/to/output_dir>
```

...will add the file `test_downsampling_summary.csv` to the outdir.

### Quality Trimming & Filtering

By default, input fastq files will be run through [fastp](https://github.com/OpenGene/fastp) using its default settings. This
means that [quality filtering](https://github.com/OpenGene/fastp?tab=readme-ov-file#quality-filter) will be applied to remove
poor-quality reads. But [quality trimming](https://github.com/OpenGene/fastp?tab=readme-ov-file#per-read-cutting-by-quality-score)
is not applied.

To disable quality filtering, use the `--disable_quality_filtering` flag. To enable quality trimming, use the `--enable_quality_trimming`
flag. For example:

```
nextflow run BCCDC-PHL/downsample-reads \
  -profile conda \
  --cache ~/.conda/envs \
  --samplesheet_input samplesheet.csv \
  --disable_quality_filtering \
  --enable_quality_trimming \
  --outdir </path/to/output_dir>
```

### Random Seed

rasusa allows users to specify a [random seed](https://github.com/mbhall88/rasusa?tab=readme-ov-file#random-seed) to be used
for its random subsampling algorithm. By default, rasusa generates a random seed at runtime using inputs from the operating system.
This pipeline sets the default random seed to `0`, which ensures that the same set of reads will be sampled given the same inputs.
A different random seed can be set using the `--random_seed` flag.

## Output

A pair of fastq.gz files will be produced for each target coverage, for each sample.
Filenames are appended with `-downsample-Nx`, where `N` is the target coverage for that file pair.

```
outdir
`-- sample-01
    |-- sample-01_25x_20240325154538_provenance.yml
    |-- sample-01_50x_20240325154538_provenance.yml
    |-- sample-01_25x_downsampling_summary.csv
    |-- sample-01_50x_downsampling_summary.csv
    |-- sample-01-downsample-25x_R1.fastq.gz
    |-- sample-01-downsample-25x_R2.fastq.gz
    |-- sample-01-downsample-50x_R1.fastq.gz
    `-- sample-01-downsample-50x_R2.fastq.gz
`-- sample-02
    |-- sample-02_10x_20240325154538_provenance.yml
    |-- sample-02_100x_20240325154538_provenance.yml
    |-- sample-02_10x_downsampling_summary.csv
    |-- sample-02_100x_downsampling_summary.csv
    |-- sample-02-downsample-10x_R1.fastq.gz
    |-- sample-02-downsample-10x_R2.fastq.gz
    |-- sample-02-downsample-100x_R1.fastq.gz
    `-- sample-02-downsample-100x_R2.fastq.gz
`-- collected_downsampling_summary.csv
```

The `collected_downsampling_summary.csv` file will include a summary of the number of reads and bases, for each sample for each target coverage, plus the `original` input files.
The depth of coverage of the output files is estimated based on the `total_bases` divided by the `genome_size`.

```csv
sample_id  total_reads  total_bases  q30_rate  genome_size  target_coverage  estimated_coverage
sample-01  2549698      383269283    0.884585  5.0m         original         76.654
sample-02  2500548      375831165    0.877859  5.0m         original         75.166
sample-03  3432324      515552128    0.887493  5.5m         original         93.737
sample-01  166352       25000128     0.884852  5.0m         5                5.0
sample-02  332658       50000175     0.877714  5.0m         10               10.0
sample-03  366112       55000224     0.887422  5.5m         10               10.0
sample-01  1663158      250000208    0.884677  5.0m         50               50.0
sample-02  1830796      275000177    0.887517  5.5m         50               50.0
sample-03  2500548      375831165    0.877859  5.0m         100              75.166
```

## Provenance

In the output directory for each sample, a provenance file will be written with the following format:

```yml
- pipeline_name: BCCDC-PHL/downsample-reads
  pipeline_version: 0.1.0
  nextflow_session_id: ceb7cc4c-644b-47bd-9469-5f3a7658119f
  nextflow_run_name: voluminous_jennings
  analysis_start_time: 2024-03-19T15:23:43.570174-07:00
- filename: NC000962_R1.fastq.gz
  file_type: fastq-input
  sha256: 2793587aeb2b87bece4902183c295213a7943ea178c83f8b5432594d4b2e3b84
- filename: NC000962_R2.fastq.gz
  file_type: fastq-input
  sha256: 336e4c42a60f22738c87eb1291270ab4ddfd918f32fa1fc662421d4f9605ea59
- process_name: fastp
  tools:
    - tool_name: fastp
      tool_version: 0.23.2
      parameters:
        - parameter: --cut_tail
          value: null
- process_name: downsample
  tools:
    - tool_name: rasusa
      tool_version: 0.7.0
      parameters:
        - parameter: --coverage
          value: 10
        - parameter: --genome-size
          value: 4.4m
        - parameter: --seed
          value: 0
- filename: NC000962-downsample-10x_R1.fastq.gz
  file_type: fastq-output
  sha256: 2fe74753d889d1b6f02832a09b10a1cab51b1fb2e16a2af20577277aded07a83
- filename: NC000962-downsample-10x_R2.fastq.gz
  file_type: fastq-output
  sha256: b6041ce11ccad3522b3f0ae4117967839ccad78a90e90f106ac399e2e23a8000
```

If multiple coverage levels are specified for a sample, then multiple provenance files will be created (one for each coverage level).