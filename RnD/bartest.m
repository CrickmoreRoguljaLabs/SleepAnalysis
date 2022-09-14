B = rand(100,3);
A = 1:100;
B(:,1) = B(:,1)/3+0.6667;
B(:,2) = B(:,2)/3+0.3333;
B(:,3) = B(:,3)/3;
figure
% hold on
% bbar1 = bar(A,B(:,1),'hist','BaseValue',0.6667);
% 
% 
% bbar2 = bar(A,B(:,2),'hist','BaseValue',0.3333);
% 
% hold off

bar(A,B,'stacked')
%%
clear ax
ax(1) = axes;
a1 = bar(ax(1), A, B(:,1),'r' );
a1.BaseValue = 0.6667;
subplot(2,3,1,ax(1))

ax(2) = axes;
a2 = bar(ax(2),  A, B(:,2),'g');
a2.BaseValue = 0.3333;
axis off % turn off the secon axes
subplot(2,3,1,ax(2))

ax(3) = axes;
a3 = bar(ax(3),  A, B(:,3),'b');
axis off % turn off the secon axes
subplot(2,3,1,ax(3))

set(ax,'YLim',[0,1]); % set the same values for both axes
linkaxes(ax)



