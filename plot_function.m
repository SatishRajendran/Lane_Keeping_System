clc;
close all;

figure(123)
plot(X_mitte_rechts,Y_mitte_rechts,'g')
hold on
grid on;
plot(Pos_X(:,2),Pos_Y(:,2),'r')
title('MPC control');
xlabel('X Position (m)');
ylabel('Y Position (m)');
legend('Path','Vehicle');

%{
figure(125)
kl=lateral_gap.signals.values;
plot(time_vector,(kl((1:kfinal),1))/10,'b');
grid on;
ylim([-0.08  0.08])
xlabel('Time in seconds');
ylabel('Lateral Gap (m)');
title('Lateral Gap with MPC control');
legend('Lateral Gap');

figure(126)
kll=psi_ddot.signals.values;
plot(time_vector,kll((1:kfinal),1),'b');
grid on;
ylim([-.1  .1])
xlabel('Time in seconds');
ylabel ( '$ \ddot{\psi} $','FontSize',16,'interpreter' , 'latex' )
%ylabel('psi_ddot (m)');
title('Yaw Acceleration with MPC control');
legend('yaw acceleration' , 'interpreter' , 'latex');

figure(1257)
kl=lateral_gap.signals.values;
plot(time_vector,l_ltr((1:kfinal),1),'b');
grid on;
ylim([-0.5  0.5])
xlabel('Time in seconds');
ylabel('Lateral Gap (m)');
title('Lateral Gap with MPC control');
legend('Lateral Gap');
% figure(126)
% plot(time_vector,l_ltr((1:kfinal),1),'b');
% grid on;
% ylim([-0.1 0.1]);
% title('Lateral Gap with MPC control');
% legend('Lateral Gap');
%}