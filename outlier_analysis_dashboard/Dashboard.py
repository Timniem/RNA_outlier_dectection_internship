from Widgets import Widgets
import panel as pn

class Dashboard:
    def __init__(self, fraser_data, outrider_data):
        self.fraser_data = fraser_data
        self.outrider_data = outrider_data
        self.widgets = Widgets(data=self.fraser_data, outrider_data=self.outrider_data, data_type=['genes','junctions'], genepanels=['none','PID'])

    def run(self):
        template = pn.template.BootstrapTemplate(
            title='RNA-seq outlier analysis'
                    )
        
        template.main.append(
            pn.Column(
                pn.Row(
                    pn.Card(self.widgets.tab, title='Outliers table'),
                    pn.Card(self.widgets.scatter_plot_app(), title='Volcano plot'),
                ),
                #pn.Row(pn.Card(self.widgets.sashimi_pdf('DATA/sashimi_PLCG2.pdf'), title="Sashimi plot", width=1340, height=850))
                )
            )
        template.sidebar.extend([self.widgets.select_patient,
                                self.widgets.genepanel_filter,
                                self.widgets.select_datatype,
                                self.widgets.pval_slider,
                                self.widgets.delta_psi_slider,
                                self.widgets.gene_input,
                                self.widgets.hpo_input,])
        return template
