
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.patches as mpatches
import numpy as np


#plt.style.use('dark_background')
font = {'size'   : 8}

mpl.rc('font', **font)

class PlotFunctions:
    def __init__(self):
        pass

    def scatter_plot(data, patient, p_cutoff=0.05,z_cutoff=4):
        data = data[data.sampleID == patient].reset_index()
        significant_data = data[(data.padjust < p_cutoff) & (abs(data.zScore) > z_cutoff)]
        rest_data = data[(data.padjust > p_cutoff) | (abs(data.zScore) < z_cutoff)]
        x_range = rest_data.zScore
        y_range = -np.log(rest_data.pValue)
        sx_range = significant_data.zScore
        sy_range = -np.log(significant_data.pValue)
        fig, ax = plt.subplots(figsize=(3.5,3.5))
        ax.scatter(x=x_range, y=y_range, color='grey', alpha=1, s=6)
        ax.scatter(x=sx_range, y=sy_range, color='red', alpha=1, s=6)
        ax.set_yscale('linear')
        ax.set_ylabel("-log10(p value)", size=8)
        ax.set_xlabel("Z score", size=8)
        z_bound = max(abs(min(data.zScore)),abs(max(data.zScore)))+1
        ax.set_xbound(lower=-z_bound,upper=z_bound)
        ax.grid(False)
        ax.set_title(f'{data.sampleID.unique()[0]}', size=8)
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        ax.yaxis.set_major_formatter(plt.FormatStrFormatter('%.f'))
        ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.f'))
        significant_data = significant_data.sort_values("pValue")
        offset_x = .2
        offset_y = 0
        outliers = len(significant_data.index)
        if  outliers > 0:
            for i in range(outliers):
                row = significant_data.iloc[i]
                ax.text(x=row.zScore+offset_x, y=-np.log(row.pValue)-offset_y, s=row.geneID, size=6)
                offset_y += .5
        plt.tight_layout()
        plt.close()
        return fig
    
    def sashimi_plot(self, bam, chr_start, chr_stop):
        """
        function takes bam, chr start/stop, and a gtf annotation file and creates sashimi plot
        """

