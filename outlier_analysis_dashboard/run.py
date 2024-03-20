from Dashboard import Dashboard
import pandas as pd
import panel as pn
from bokeh.io import output_notebook, push_notebook, show, save, output_file
from bokeh.resources import INLINE
import sys

def main():
    fraser_data = pd.read_csv(sys.argv[1], sep='\t')
    outrider_data = pd.read_csv(sys.argv[2], sep='\t')
    try:
        mae_data = pd.read_csv(sys.argv[3], sep='\t')
    except FileNotFound:
        #creation of dummy data
        mae_data = pd.DataFrame({"sampleID":[],"hgncSymbol":[], "padj":[], "log2FC":[] })
    dashboard = Dashboard(fraser_data, outrider_data, mae_data).run()
    dashboard.servable()
main()
