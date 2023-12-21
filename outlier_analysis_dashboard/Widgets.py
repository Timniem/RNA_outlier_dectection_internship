from Plotfunctions import PlotFunctions
import pandas as pd
import panel as pn


class Widgets:
    def __init__(self, data, outrider_data, data_type, genepanels):
        self.data = data
        self.outrider_data = outrider_data
        self.patients = [patient for patient in data.sampleID.unique()]
        self.plot_functions = PlotFunctions
        self.select_patient = pn.widgets.Select(name='Select Patient',options=self.patients, width=200)
        self.select_datatype = pn.widgets.Select(name='Select Data', options=data_type, width=200)
        self.genepanel_filter = pn.widgets.Select(name='Select Genepanel', options=genepanels, width=200)
        self.pval_slider = pn.widgets.FloatSlider(name='pValue cut off', value=0.05, start=0.00, end=0.99, step=0.01)
        self.delta_psi_slider = pn.widgets.FloatSlider(name='deltaPsi cut off', value=0.1, start=0, end=1, step=0.05)
        self.gene_input = pn.widgets.TextInput(name='Search gene(s)', placeholder='e.g. PLCG2, IL12R, ..')
        self.hpo_input = pn.widgets.TextInput(name='Search HPO', placeholder='e.g. HP:0000001, HP:0000002, ..')
        self.tab = pn.Column(pn.bind(self.tabulator, patient=self.select_patient, p_cutoff = self.pval_slider.param.value_throttled,
                                     gene_panel=self.genepanel_filter, psi_cutoff=self.delta_psi_slider.param.value_throttled,
                                       selected_genes = self.gene_input, hpo_terms=self.hpo_input ))
        self.refresh_button = pn.widgets.Button(name="refresh sashimi", button_type='primary', width=200, height=50)
        
    def scatter_plot_app(self): 
        interactive = pn.bind(
            self.plot_functions.scatter_plot_fraser, data=self.data,
            patient=self.select_patient, p_cutoff=self.pval_slider.param.value_throttled,
            gene_panel=self.genepanel_filter,
            psi_cutoff=self.delta_psi_slider.param.value_throttled)
        return pn.Column(interactive)
    
    def get_hpo_genes(self, hpo_terms):
        genes = None
        if hpo_terms:
            hpo_terms = [hpo_term.strip() for hpo_term in hpo_terms.split(',')]
            hpo_file = pd.read_csv('resources/phenotype_to_genes.txt', sep='\t')
            genes = hpo_file.gene_symbol[hpo_file.hpo_id.isin(hpo_terms)].unique().tolist()
        return genes

    def tabulator(self, patient, p_cutoff, psi_cutoff, gene_panel, selected_genes, hpo_terms):
        if gene_panel != 'none':
            with open(f'resources/gene_panels/{gene_panel}.txt') as gene_file:
                genes = [line.strip() for line in gene_file]
                data = self.data[self.data.hgncSymbol.isin(genes)]
        else:
            data = self.data
        if selected_genes !='':
            selected_genes = [gene.strip() for gene in selected_genes.split(',')]
            data = data[self.data.hgncSymbol.isin(selected_genes)]

        hpo_genes = self.get_hpo_genes(hpo_terms=hpo_terms)

        if hpo_genes:
            data = data[self.data.hgncSymbol.isin(hpo_genes)]

        tab = pn.widgets.Tabulator(
            data[(data.sampleID == patient) &
                        (data.padjust < p_cutoff) &
                        (abs(data.deltaPsi) > psi_cutoff)].drop(columns=
                            ["sampleID", "strand"]
                        ),
            selection=[0],
            width=750,height=505, show_index=False, disabled=True,
            page_size=15,layout='fit_data')
        return tab
    def sashimi_pdf(self, link):
        sashimi = pn.pane.PDF(link, width=1320,height=800)
        return sashimi

    

