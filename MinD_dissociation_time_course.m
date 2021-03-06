
% load data, parameter values, initial conditions, etc
load('MinD_dissociation.mat')

% define parameter names as parameter values
for i=1:length(MinD_dissociation.parameter_names)
    eval([char(MinD_dissociation.parameter_names(i)),' = MinD_dissociation.parameter_values(',int2str(i),');']);
end

% define the AABSM (for MinD dissociation with MinE in the flowed buffer)
c_d_prime = @(c_d, c_de, c_ded, c_e) ...
    -w__E_d_to_de*c_d ...
    -w__E_d_to_de__by_de*c_d*c_de ...
    -w__E_d_to_de__by_ded*c_d*c_ded ...
    -w__E_d_to_de__by_e*c_d*c_e ...
    -w__d_to_D*c_s^n_s/(c_s^n_s+(c_d_bar+c_d+c_de+2*c_ded).^n_s)*c_d ...
    -w__d_de_to_ded*c_d*c_de ...
    -w__d_e_to_de*c_d*c_e ...
    +w__de_to_d_E*c_de ...
    +w__de_to_d_e*c_de ...    
    +w__ded_to_D_E_d*c_ded ...
    +w__ded_to_D_e_d*c_ded ...
    +w__ded_to_d_de*c_ded;

c_de_prime = @(c_d, c_de, c_ded, c_e) ...
    w__E_d_to_de*c_d ...
    +w__E_d_to_de__by_de*c_d*c_de ...
    +w__E_d_to_de__by_ded*c_d*c_ded ...
    +w__E_d_to_de__by_e*c_d*c_e ...
    +2*w__E_ded_to_de_de*c_ded ...
    +2*w__E_ded_to_de_de__by_de*c_ded*c_de ...
    +2*w__E_ded_to_de_de__by_ded*c_ded*c_ded ...
    +2*w__E_ded_to_de_de__by_e*c_ded*c_e ...
    -w__d_de_to_ded*c_d*c_de ...
    +w__d_e_to_de*c_d*c_e ...
    -2*w__de_de_to_ded_E*c_de.^2 ...
    -2*w__de_de_to_ded_e*c_de.^2 ...
    -w__de_to_D_E*c_de ...
    -w__de_to_D_e*c_de ...
    -w__de_to_d_E*c_de ...
    -w__de_to_d_e*c_de ...
    +w__ded_to_D_de*c_ded ...
    +w__ded_to_d_de*c_ded ...
    +2*w__ded_e_to_de_de*c_ded*c_e;

c_ded_prime = @(c_d, c_de, c_ded, c_e) ...
    -w__E_ded_to_de_de*c_ded ...
    -w__E_ded_to_de_de__by_de*c_ded*c_de ...
    -w__E_ded_to_de_de__by_ded*c_ded*c_ded ...
    -w__E_ded_to_de_de__by_e*c_ded*c_e ...
    +w__d_de_to_ded*c_d*c_de ...
    +w__de_de_to_ded_E*c_de.^2 ...
    +w__de_de_to_ded_e*c_de.^2 ...
    -w__ded_to_D_E_D*c_ded ...
    -w__ded_to_D_E_d*c_ded ...
    -w__ded_to_D_de*c_ded ...
    -w__ded_to_D_e_D*c_ded ...
    -w__ded_to_D_e_d*c_ded ...
    -w__ded_to_d_de*c_ded ...
    -w__ded_e_to_de_de*c_ded*c_e;

c_e_prime = @(c_d, c_de, c_ded, c_e) ...
    -w__d_e_to_de*c_d*c_e ...
    +w__de_de_to_ded_e*c_de.^2 ...
    +w__de_to_D_e*c_de ...
    +w__de_to_d_e*c_de ...
    +w__ded_to_D_e_D*c_ded ...
    +w__ded_to_D_e_d*c_ded ...
    -w__ded_e_to_de_de*c_ded*c_e ...
    -w__e_to_E*c_e;

AABSM = @(y) [c_d_prime(y(1),y(2),y(3),y(4)); c_de_prime(y(1),y(2),y(3),y(4)); ...
    c_ded_prime(y(1),y(2),y(3),y(4)); c_e_prime(y(1),y(2),y(3),y(4))];

% define the AABSM for MinD dissociation with MinE absent
c_d_prime__MinE_absent = @(c_d) ...
    -w__d_to_D*c_s^n_s/(c_s^n_s+(c_d_bar__MinE_absent+c_d).^n_s)*c_d;

AABSM__MinE_absent = @(y) c_d_prime__MinE_absent(y);

% solve the AABSM numerically
[~,AABSM_solution] = ode15s(@(t,y) AABSM(y), MinD_dissociation.data_time, MinD_dissociation.initial_condition);
[~,AABSM_solution__MinE_absent] = ode15s(@(t,y) AABSM__MinE_absent(y), MinD_dissociation.data_time__MinE_absent, ...
    MinD_dissociation.initial_condition__MinE_absent);

% determine MinD and MinE concentrations from the AABSM solutions
AABSM_MinD = 2*AABSM_solution(:,1) + 2*AABSM_solution(:,2) + 4*AABSM_solution(:,3) + C_d;
AABSM_MinE = 2*AABSM_solution(:,2) + 2*AABSM_solution(:,3) + 2*AABSM_solution(:,4) + C_e;
AABSM_MinD__MinE_absent = 2*AABSM_solution__MinE_absent + C_d__MinE_absent;

% plot the AABSM solutions and the MinD dissociation data
figure(1)
plot(MinD_dissociation.data_time, AABSM_MinD, 'g', ...
    MinD_dissociation.data_time, AABSM_MinE, 'r',...
    MinD_dissociation.data_time__MinE_absent, AABSM_MinD__MinE_absent, 'k', ...
    MinD_dissociation.data_time, MinD_dissociation.data_values(:,1), 'g.', ...
    MinD_dissociation.data_time, MinD_dissociation.data_values(:,2), 'r.',...
    MinD_dissociation.data_time__MinE_absent, MinD_dissociation.data_values__MinE_absent, 'k.',...
    'LineWidth', 1, 'MarkerSize', 5)
axis tight
set(gca, 'fontsize', 14)
x_label = xlabel('time (s)');
set(x_label, 'fontsize', 14);
y_label = ylabel('density (\mum^{-2})');
set(y_label, 'fontsize', 14);
legend_handle = legend({'MinD','MinE','MinD only'});
legend('boxoff')
