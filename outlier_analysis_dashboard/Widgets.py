from Plotfunctions import PlotFunctions
import numpy as np
import os
import panel as pn



class Widgets:
    def __init__(self, data, data_type, genepanels):
        self.data = data
        self.patients = [patient for patient in data.sampleID.unique()]
        self.plot_functions = PlotFunctions
        self.select_patient = pn.widgets.Select(name='Select Patient',options=self.patients, width=200)
        self.select_datatype = pn.widgets.Select(name='Select Data', options=data_type, width=200)
        self.genepanel_filter = pn.widgets.Select(name='Select Genepanel', options=genepanels, width=200)
        self.pval_slider = pn.widgets.FloatSlider(name='pValue cut off', value=0.05, start=0.00, end=0.99, step=0.01)
        self.zscore_slider = pn.widgets.FloatSlider(name='zScore cut off', value=4, start=0, end=10, step=0.5)
        self.tab = pn.Column(pn.bind(self.tabulator, patient=self.select_patient, p_cutoff = self.pval_slider.param.value_throttled,
                                     z_cutoff = self.zscore_slider.param.value_throttled))
        self.refresh_button = pn.widgets.Button(name="refresh sashimi", button_type='primary', width=200, height=50)

    def scatter_plot_app(self): 
        interactive = pn.bind(
            self.plot_functions.scatter_plot, data=self.data,
            patient=self.select_patient, p_cutoff=self.pval_slider.param.value_throttled,
            z_cutoff=self.zscore_slider.param.value_throttled)
        return pn.Column(interactive)
    
    def tabulator(self, patient, p_cutoff, z_cutoff):
        tab = pn.widgets.Tabulator(
            self.data[(self.data.sampleID == patient) &
                        (self.data.padjust < p_cutoff) &
                        (abs(self.data.zScore) > z_cutoff)].drop(columns=
                            ["sampleID","padj_rank","TIN_mean","link_bam",
                             "chr","start","end","gene","transcript",
                             "aberrant","AberrantByGene", "AberrantBySample",
                             "sample_name", "pValue","l2fc"]
                        ),
            selection=[0],
            width=750,height=505, show_index=False, disabled=True,
            page_size=15,layout='fit_data')
        return tab
    def sashimi_pdf(self, link):
        sashimi = pn.pane.PDF(link, width=1320,height=800)
        return sashimi

    

