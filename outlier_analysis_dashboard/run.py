from Dashboard import Dashboard
import pandas as pd
import panel as pn
from bokeh.io import output_notebook, push_notebook, show, save, output_file
from bokeh.resources import INLINE



def main():
    fraser_data = pd.read_csv("DATA/result_table_fraser.tsv", sep='\t')
    outrider_data = pd.read_csv("DATA/result_table_outrider.tsv", sep='\t')
    mae_data = pd.read_csv("DATA/result_table_mae.tsv", sep='\t')
    dashboard = Dashboard(fraser_data, outrider_data, mae_data).run()
    dashboard.servable()
main()
