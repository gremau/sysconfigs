wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh -O ~/data/miniconda.sh

cd ~/data/

bash miniconda.sh

conda env remove --yes -n std_env    # remove the environement std_env if it exists (optional)

conda create --yes -n std_env pip numpy pandas scipy matplotlib jupyterlab seaborn

activate std_env
# pip install modules if needed, run python scripts, etc
# everything will be installed in the new_env
# located in ~/miniconda/envs/new_env

deactivate
