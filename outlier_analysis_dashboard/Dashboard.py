from Widgets import Widgets
import panel as pn

class Dashboard:
    def __init__(self, fraser_data, outrider_data, mae_data):
        self.fraser_data = fraser_data
        self.outrider_data = outrider_data
        self.mae_data = mae_data
        self.widgets = Widgets(fraser_data=self.fraser_data, outrider_data=self.outrider_data, mae_data=self.mae_data, genepanels=['none','PID'])

    def run(self):
        template = pn.Column(
            pn.pane.Markdown(
            """
            # RNA seq outliers dashboard

            """, styles={'background': '#f3f3f3'}, width=1805
        ),
            pn.Row(
            pn.Column(pn.Row(self.widgets.select_patient),
                                pn.Row(self.widgets.genepanel_filter),
                                pn.Row(self.widgets.gene_input),
                                pn.Row(self.widgets.hpo_input),
                                pn.Row(pn.widgets.StaticText(name='controls', value="FRASER")),
                                pn.Row(self.widgets.pval_slider_fraser),
                                pn.Row(self.widgets.delta_psi_slider),
                                pn.Row(pn.widgets.StaticText(name='controls', value="OUTRIDER")),
                                pn.Row(self.widgets.pval_slider_outrider),
                                pn.Row(self.widgets.zscore_slider),
                                pn.Row(pn.widgets.StaticText(name='controls', value="MAE")),
                                pn.Row(self.widgets.pval_slider_mae),
                                pn.Row(self.widgets.log2fc_slider_mae)),
            pn.Column(
                pn.Row(
                    pn.Card(pn.Row(self.widgets.fraser_tab, self.widgets.scatter_plot_fraser(), styles={'background': '#f3f3f3'}), title='Splicing outliers FRASER'),
                ),
                pn.Row(
                    pn.Card(pn.Row(self.widgets.outrider_tab, self.widgets.scatter_plot_outrider(), styles={'background': '#f3f3f3'}), title='Expression outliers OUTRIDER')
                ),
                pn.Row(
                    pn.Card(pn.Row(self.widgets.mae_tab, self.widgets.mae_plot(), styles={'background': '#f3f3f3'}), title='Mono Allelic Expression variants')
                )
                )
            )
        )
        return template
