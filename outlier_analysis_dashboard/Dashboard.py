from Widgets import Widgets
import panel as pn

class Dashboard:
    def __init__(self, fraser_data, outrider_data):
        self.fraser_data = fraser_data
        self.outrider_data = outrider_data
        self.widgets = Widgets(fraser_data=self.fraser_data, outrider_data=self.outrider_data, genepanels=['none','PID'])

    def run(self):
        template = pn.template.BootstrapTemplate(
            title='RNA-seq outlier analysis'
                    )
        
        template.main.append(
            pn.Column(
                pn.Row(
                    pn.Card(self.widgets.fraser_tab, title='Outliers FRASER'),
                    pn.Card(self.widgets.scatter_plot_fraser(), title='Volcano FRASER'),
                ),
                pn.Row(
                    pn.Card(self.widgets.outrider_tab, title='Outliers OUTRIDER'),
                    pn.Card(self.widgets.scatter_plot_outrider(), title='Volcano OUTRIDER'))
                )
            )
        template.sidebar.extend([self.widgets.select_patient,
                                self.widgets.genepanel_filter,
                                self.widgets.gene_input,
                                self.widgets.hpo_input,
                                pn.widgets.StaticText(name='controls', value="FRASER"),
                                self.widgets.pval_slider_fraser,
                                self.widgets.delta_psi_slider,
                                pn.widgets.StaticText(name='controls', value="OUTRIDER"),
                                self.widgets.pval_slider_outrider,
                                self.widgets.zscore_slider])
        return template
