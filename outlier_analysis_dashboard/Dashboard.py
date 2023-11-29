from Widgets import Widgets
import panel as pn

class Dashboard:
    def __init__(self, data):
        self.data = data
        self.widgets = Widgets(data=self.data, data_type=['genes','introns','exons','junctions'], genepanels=['PID','Cardio','Onco', 'etc.'])

    def run(self):
        # Instantiate the template with widgets displayed in the sidebar
        template = pn.template.BootstrapTemplate(
            title='RNA-seq outlier analysis'
                    )
        # Append a layout to the main area, to demonstrate the list-like API
        template.main.append(
            pn.Column(
                pn.Row(
                    pn.Card(self.widgets.tab, title='Outliers table'),
                    pn.Card(self.widgets.scatter_plot_app(), title='Volcano plot'),
                ),
                pn.Row(pn.Card(self.widgets.sashimi_pdf('/home/tim/RNA_outlier_webapp/Data/sashimis/SmartFish3D.pdf'), title="Sashimi plot", width=1340, height=850))
                )
            )
        template.sidebar.extend([self.widgets.select_patient,
                                self.widgets.genepanel_filter,
                                self.widgets.select_datatype,
                                self.widgets.pval_slider,
                                self.widgets.zscore_slider,
                                self.widgets.refresh_button])
        return template
