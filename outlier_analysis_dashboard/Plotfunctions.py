
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np


#plt.style.use('dark_background')
font = {'size'   : 8}

mpl.rc('font', **font)

class PlotFunctions:
    def __init__(self):
        pass

    def scatter_plot_fraser(data, patient, gene_panel, p_cutoff=0.05, psi_cutoff=0.1):
        data = data.replace([np.inf, -np.inf], 1)
        data = data.replace(np.NaN, 1)
        data = data[data.sampleID == patient].reset_index()
        if gene_panel != 'none':
            with open(f'resources/gene_panels/{gene_panel}.txt') as gene_file:
                genes = [line.strip() for line in gene_file]
            significant_data = data[(data.padjust < p_cutoff) & (abs(data.deltaPsi) > psi_cutoff) & (data.hgncSymbol.isin(genes))]
            rest_data = data[(data.padjust > p_cutoff) | (abs(data.deltaPsi) < psi_cutoff) | (~data.hgncSymbol.isin(genes))]
        else:
            significant_data = data[(data.padjust < p_cutoff) & (abs(data.deltaPsi) > psi_cutoff)]
            rest_data = data[(data.padjust > p_cutoff) | (abs(data.deltaPsi) < psi_cutoff)]
        x_range = rest_data.deltaPsi
        y_range = -np.log(rest_data.pValue)
        sx_range = significant_data.deltaPsi
        sy_range = -np.log(significant_data.pValue)
        fig, ax = plt.subplots(figsize=(3.5,3.5))
        ax.scatter(x=x_range, y=y_range, color='grey', alpha=.6, s=8, edgecolors='none')
        ax.scatter(x=sx_range, y=sy_range, color='blue', alpha=.6, s=8, edgecolors='none')
        ax.set_yscale('linear')
        ax.set_ylabel("-log10(p value)", size=8)
        ax.set_xlabel("deltaPsi", size=8)
        ax.set_xbound(lower=-1.1,upper=1.1)
        ax.grid(False)
        ax.set_title(f'{data.sampleID.unique()[0]}', size=8)
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        ax.yaxis.set_major_formatter(plt.FormatStrFormatter('%.f'))
        ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        significant_data = significant_data.sort_values("pValue")
        plt.tight_layout()
        plt.close()
        return fig
    
    def scatter_plot_outrider(data, patient, gene_panel, p_cutoff=0.05, z_cutoff=4):
        data = data.replace([np.inf, -np.inf], 1)
        data = data.replace(np.NaN, 1)
        data = data[data.sampleID == patient].reset_index()
        if gene_panel != 'none':
            with open(f'resources/gene_panels/{gene_panel}.txt') as gene_file:
                genes = [line.strip() for line in gene_file]
            significant_data = data[(data.padjust < p_cutoff) & (abs(data.zScore) > z_cutoff) & (data.hgncSymbol.isin(genes))]
            rest_data = data[(data.padjust > p_cutoff) | (abs(data.zScore) < z_cutoff) | (~data.hgncSymbol.isin(genes))]
        else:
            significant_data = data[(data.padjust < p_cutoff) & (abs(data.zScore) > z_cutoff)]
            rest_data = data[(data.padjust > p_cutoff) | (abs(data.zScore) < z_cutoff)]
        x_range = rest_data.zScore
        y_range = -np.log(rest_data.pValue)
        sx_range = significant_data.zScore
        sy_range = -np.log(significant_data.pValue)
        fig, ax = plt.subplots(figsize=(3.5,3.5))
        ax.scatter(x=x_range, y=y_range, color='grey', alpha=.6, s=8, edgecolors='none')
        ax.scatter(x=sx_range, y=sy_range, color='blue', alpha=.6, s=8, edgecolors='none')
        ax.set_yscale('linear')
        ax.set_ylabel("-log10(p value)", size=8)
        ax.set_xlabel("zScore", size=8)
        ax.set_xbound(lower=-1.1,upper=1.1)
        ax.grid(False)
        ax.set_title(f'{data.sampleID.unique()[0]}', size=8)
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        ax.yaxis.set_major_formatter(plt.FormatStrFormatter('%.f'))
        ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        significant_data = significant_data.sort_values("pValue")
        plt.tight_layout()
        plt.close()
        return fig
    
    def sashimi_plot(self, bam, chr_start, chr_stop):
        """
        function takes bam, chr start/stop, and a gtf annotation file and creates sashimi plot
        Not yet implemented.
        """

