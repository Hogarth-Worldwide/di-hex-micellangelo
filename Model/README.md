This code is related to training and evaluation of the generative models used in the paper. 

# Setup
To download the code and install the dependencies, run:

```
pip install -r requirements.txt
```

# Data

Download the data (.mat files) and place it in the 'data' directory.


# Training

The main training script is topo-chip-train.py. To train a model, run a command like below:

```
python topochip-train.py --output_dir "./default_results/" <--param_name> <param_value> <--param_name2> <param_value2> ...
```

Not providing any parameters apart from output_dir will run the default configuration corresponding to the main model of the paper. The trained model weights of this model can be found under model_weights/otcfm_topo_weights_step_145000.pt.
To run the Data-Dependent Coupling variant (for cell completion), use:

```
python topochip-train.py --output_dir "./ddc_results/" --model "icfm" --use_ddc;
```

Weights for this model can be found under model_weights/icfm_topo_weights_step_345000.pt.

Please consult the topochip-train file for more details on parameters.

# Generating synthetic images

To generate synthetic images using a trained model, use the generate_fake_tiffs.py script:

```
python generate_fake_tiffs.py;
```

This will generate images from the pretrained model, please see the script if you want to change some parameters.

# Evaluation:

To compare real and generated cells, see the evaluation directory. Pre-computed statistics are provided in the zip files in the evaluation/cp_output_archive directory; you can unzip these to run the analysis on. Alternatively, first run the real_imgs_to_tiff.ipynb notebook to prepare the real data for CellProfiler processing, and then use the cp-pipeline-main.cpproj file with CellProfiler to separately analyse real and fake cells and extract the statistics. 
Finally, the paper_plots_*.ipynb notebooks in the directory can be used for the analysis.



