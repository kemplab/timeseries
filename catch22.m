function out = catch22(y)

% no combination of single functions
coder.inline('never');

% z-score
y = (y - mean(y))/std(y);

out = zeros(20,1);

out(1) = DN_HistogramMode_5(y);
out(2) = DN_HistogramMode_10(y);
out(3) = CO_f1ecac(y);
out(4) = CO_FirstMin_ac(y);
out(5) = CO_HistogramAMI_even_2_5(y);
out(6) = CO_trev_1_num(y);
out(7) = MD_hrv_classic_pnn40(y); 
out(8) = SB_BinaryStats_mean_longstretch1(y); 
out(9) = SB_TransitionMatrix_3ac_sumdiagcov(y); 
out(10) = PD_PeriodicityWang_th0_01(y);
out(11) = CO_Embed2_Dist_tau_d_expfit_meandiff(y);
out(12) = IN_AutoMutualInfoStats_40_gaussian_fmmi(y); 
out(13) = FC_LocalSimple_mean1_tauresrat(y);
out(14) = DN_OutlierInclude_p_001_mdrmd(y);
out(15) = DN_OutlierInclude_n_001_mdrmd(y);
out(16) = SP_Summaries_welch_rect_area_5_1(y); 
out(17) = SB_BinaryStats_diff_longstretch0(y);
out(18) = SB_MotifThree_quantile_hh(y);
out(19) = SP_Summaries_welch_rect_centroid(y);
out(20) = FC_LocalSimple_mean3_stderr(y); 