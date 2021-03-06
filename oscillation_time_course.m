
% load data, parameter values, initial conditions, etc
load('oscillation.mat')

% define parameter names as parameter values
for i=1:length(oscillation.parameter_names)
    eval([char(oscillation.parameter_names(i)),' = oscillation.parameter_values(',int2str(i),');']);
end

% define the AABSM
c_d_prime = @(c_d, c_de, c_ded, c_e) ...
    w__D_to_d*(c_max-c_d_bar-c_d-c_de-2*c_ded)/c_max ...
    +w__D_to_d__by_d*(c_max-c_d_bar-c_d-c_de-2*c_ded)/c_max*c_d ...
    +w__D_to_d__by_de*(c_max-c_d_bar-c_d-c_de-2*c_ded)/c_max*c_de ...
    +w__D_to_d__by_ded*(c_max-c_d_bar-c_d-c_de-2*c_ded)/c_max*c_ded ...
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

% solve the AABSM numerically
[~,AABSM_solution] = ode15s(@(t,y) AABSM(y), oscillation.data_time, oscillation.initial_condition);

% determine MinD and MinE concentrations from the AABSM solution
AABSM_MinD = 2*AABSM_solution(:,1) + 2*AABSM_solution(:,2) + 4*AABSM_solution(:,3) + C_d;
AABSM_MinE = 2*AABSM_solution(:,2) + 2*AABSM_solution(:,3) + 2*AABSM_solution(:,4) + C_e;

% plot the AABSM solution and the oscillation data
figure(1)
plot(oscillation.data_time, AABSM_MinD, 'g', ...
    oscillation.data_time, AABSM_MinE, 'r',...
    oscillation.data_time, oscillation.data_values(:,1), 'g.', ...
    oscillation.data_time, oscillation.data_values(:,2), 'r.',...
    'LineWidth', 1, 'MarkerSize', 5)
axis tight
set(gca, 'fontsize', 14)
x_label = xlabel('time (s)');
set(x_label, 'fontsize', 14);
y_label = ylabel('density (\mum^{-2})');
set(y_label, 'fontsize', 14);
legend_handle = legend({'MinD','MinE'});
legend('boxoff')
