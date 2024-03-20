from Plotfunctions import PlotFunctions
import pandas as pd
import panel as pn


class Widgets:
    def __init__(self, fraser_data, outrider_data, mae_data, genepanels):
        self.fraser_data = fraser_data
        self.outrider_data = outrider_data
        self.mae_data = mae_data
        self.patients = [patient for patient in fraser_data.sampleID.unique()]
        self.plot_functions = PlotFunctions
        self.select_patient = pn.widgets.Select(name='Select Patient',options=self.patients, width=200)
        self.genepanel_filter = pn.widgets.Select(name='Select Genepanel', options=genepanels, width=200)
        self.pval_slider_fraser = pn.widgets.FloatSlider(name='pValue cut off', value=0.05, start=0.00, end=0.99, step=0.01, width=200)
        self.pval_slider_outrider = pn.widgets.FloatSlider(name='pValue cut off', value=0.05, start=0.00, end=0.99, step=0.01, width=200)
        self.delta_psi_slider = pn.widgets.FloatSlider(name='deltaPsi cut off', value=0.1, start=0, end=1, step=0.05, width=200)
        self.zscore_slider = pn.widgets.FloatSlider(name='zScore cut off', value=2.0, start=0, end=8, step=0.25, width=200)
        self.pval_slider_mae = pn.widgets.FloatSlider(name="pValue cut off", value=0.05, start=0.00, end=0.99, step=0.01, width=200)
        self.log2fc_slider_mae = pn.widgets.FloatSlider(name="log2FC cut off", value=10, start=0, end=20, step=1, width=200)
        self.gene_input = pn.widgets.TextInput(name='Search gene(s)', placeholder='e.g. PLCG2, IL12R, ..', width=200)
        self.hpo_input = pn.widgets.TextInput(name='Search HPO', placeholder='e.g. HP:0000001, HP:0000002, ..', width=200)

        self.fraser_tab = pn.Column(pn.bind(self.fraser_tabulator, patient=self.select_patient, p_cutoff = self.pval_slider_fraser.param.value_throttled,
                                     gene_panel=self.genepanel_filter, psi_cutoff=self.delta_psi_slider.param.value_throttled,
                                       selected_genes = self.gene_input, hpo_terms=self.hpo_input ))
        
        self.outrider_tab = pn.Column(pn.bind(self.outrider_tabulator, patient=self.select_patient, p_cutoff = self.pval_slider_outrider.param.value_throttled,
                                     gene_panel=self.genepanel_filter, z_cutoff=self.zscore_slider.param.value_throttled,
                                       selected_genes = self.gene_input, hpo_terms=self.hpo_input ))
        self.mae_tab = pn.Column(pn.bind(self.mae_tabulator, patient=self.select_patient, p_cutoff=self.pval_slider_mae.param.value_throttled,
                                    gene_panel=self.genepanel_filter, log2fc_cutoff=self.log2fc_slider_mae, selected_genes = self.gene_input, hpo_terms=self.hpo_input))
        
    def scatter_plot_fraser(self): 
        interactive = pn.bind(
            self.plot_functions.scatter_plot_fraser, data=self.fraser_data,
            patient=self.select_patient, p_cutoff=self.pval_slider_fraser.param.value_throttled,
            gene_panel=self.genepanel_filter,
            psi_cutoff=self.delta_psi_slider.param.value_throttled
            )
        return pn.Column(interactive)
    
    def scatter_plot_outrider(self): 
        interactive = pn.bind(
            self.plot_functions.scatter_plot_outrider, data=self.outrider_data,
            patient=self.select_patient, p_cutoff=self.pval_slider_outrider.param.value_throttled,
            gene_panel=self.genepanel_filter,
            z_cutoff=self.zscore_slider.param.value_throttled
            )
        return pn.Column(interactive)

    def mae_plot(self):
        interactive = pn.bind(
            self.plot_functions.mae_plot, data=self.mae_data,
            patient=self.select_patient, gene_panel=self.genepanel_filter, p_cutoff=self.pval_slider_mae.param.value_throttled,
            log2fc_cutoff= self.log2fc_slider_mae.param.value_throttled
            )
        return pn.Column(interactive)
    
    def get_hpo_genes(self, hpo_terms):
        genes = None
        if hpo_terms:
            hpo_terms = [hpo_term.strip() for hpo_term in hpo_terms.split(',')]
            hpo_file = pd.read_csv('resources/phenotype_to_genes.txt', sep='\t')
            genes = hpo_file.gene_symbol[hpo_file.hpo_id.isin(hpo_terms)].unique().tolist()
        return genes

    def fraser_tabulator(self, patient, p_cutoff, psi_cutoff, gene_panel, selected_genes, hpo_terms):
        if gene_panel != 'none':
            with open(f'resources/gene_panels/{gene_panel}.txt') as gene_file:
                genes = [line.strip() for line in gene_file]
                data = self.fraser_data[self.fraser_data.hgncSymbol.isin(genes)]
        else:
            data = self.fraser_data
        if selected_genes !='':
            selected_genes = [gene.strip() for gene in selected_genes.split(',')]
            data = data[self.fraser_data.hgncSymbol.isin(selected_genes)]

        hpo_genes = self.get_hpo_genes(hpo_terms=hpo_terms)

        if hpo_genes:
            data = data[self.fraser_data.hgncSymbol.isin(hpo_genes)]

        tab = pn.widgets.Tabulator(
            data[(data.sampleID == patient) &
                        (data.padjust < p_cutoff) &
                        (abs(data.deltaPsi) > psi_cutoff)].drop(columns=
                            ["sampleID", "strand"]
                        ),
            selection=[0],
            width=1100,height=505, show_index=False, disabled=True,
            page_size=15,layout='fit_data')
        return tab
    
    def outrider_tabulator(self, patient, p_cutoff, z_cutoff, gene_panel, selected_genes, hpo_terms):
        if gene_panel != 'none':
            with open(f'resources/gene_panels/{gene_panel}.txt') as gene_file:
                genes = [line.strip() for line in gene_file]
                data = self.outrider_data[self.outrider_data.hgncSymbol.isin(genes)]
        else:
            data = self.outrider_data
        if selected_genes !='':
            selected_genes = [gene.strip() for gene in selected_genes.split(',')]
            data = data[self.outrider_data.hgncSymbol.isin(selected_genes)]

        hpo_genes = self.get_hpo_genes(hpo_terms=hpo_terms)

        if hpo_genes:
            data = data[self.outrider_data.hgncSymbol.isin(hpo_genes)]

        tab = pn.widgets.Tabulator(
            data[(data.sampleID == patient) &
                        (data.padjust < p_cutoff) &
                        (abs(data.zScore) > z_cutoff)].drop(columns=
                            ["sampleID"]
                        ),
            selection=[0],
            width=1100,height=505, show_index=False, disabled=True,
            page_size=15,layout='fit_data')
        return tab

    def mae_tabulator(self, patient, p_cutoff, log2fc_cutoff, gene_panel, selected_genes, hpo_terms):
        if gene_panel != 'none':
            with open(f'resources/gene_panels/{gene_panel}.txt') as gene_file:
                genes = [line.strip() for line in gene_file]
                data = self.mae_data[self.mae_data.hgncSymbol.isin(genes)]
        else:
            data = self.mae_data
        if selected_genes !='':
            selected_genes = [gene.strip() for gene in selected_genes.split(',')]
            data = data[data.hgncSymbol.isin(selected_genes)]

        hpo_genes = self.get_hpo_genes(hpo_terms=hpo_terms)

        if hpo_genes:
            data = data[data.hgncSymbol.isin(hpo_genes)]
        tab = pn.widgets.Tabulator(
            data[(data.sampleID == patient) &
                        (data.padj < p_cutoff) &
                        (abs(data.log2FC) > log2fc_cutoff)].drop(columns=
                            ["sampleID"]
                        ),
            selection=[0],
            width=1100,height=505, show_index=False, disabled=True,
            page_size=15,layout='fit_data')
        return tab
    

