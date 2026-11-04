% plot_fisher_density.m

paths = init_project();
outdir_comp = paths.figures;

%% Set up phimean, thetamean, and kappa
thetamean = 45; 
phimean = 70;
kappa = 200;

%% Set up phi/theta grid

% ORIG
phi = linspace(0,2.*pi,500);
theta = linspace(0,pi,500);

% NEW
%phi = linspace(0,2.*pi,50);
%theta = linspace(0,pi,50);

p = 3;

alph = 0.65;
rmax = 1.1;

xmean = sind(thetamean).*cosd(phimean);
ymean = sind(thetamean).*sind(phimean);
zmean = cosd(thetamean);

x = sin(theta)'*cos(phi);
y = sin(theta)'*sin(phi);
z = repmat(cos(theta)',[1 length(phi)]);

r = [x(:) y(:) z(:)];

% ORIG
ngrid = 500;

% NEW
%ngrid = 200;

xgrid = linspace(-1,1,ngrid);
ygrid = linspace(-1,1,ngrid);

[xmesh,ymesh] = ndgrid(xgrid,ygrid);

mu_tot = [xmean,ymean,zmean];

mu = mu_tot./norm(mu_tot);

%% Normalization coefficient
Coeff = (kappa/2)^(p/2-1) * (gamma((p-1)/2)*gamma(1/2)*besseli(p/2-1,kappa)).^(-1);

f_fisher = reshape(Coeff.*exp(kappa.*(mu_tot*r')),[length(theta) length(phi)]);

f_fisher_grid = reshape(griddata(x(:),y(:),f_fisher(:),xmesh(:),ymesh(:),'cubic'),[ngrid ngrid]);

f_fisher(f_fisher<0.01) = NaN;

%% Set up figure
figure;
surf(x,y,z,f_fisher,'linestyle','none','FaceAlpha',alph,'EdgeColor','none');
colormap(0.95.*flipud(bone))
hold on;
arrow3d([0 mu(:,1)],[0 mu(:,2)],[0 mu(:,3)],0.8,0.025,2.*0.04,'r');
axis equal

xlim([-rmax rmax])
ylim([-rmax rmax]);
zlim([-rmax rmax]);
surf(xmesh,ymesh,-rmax.*ones(size(xmesh)),f_fisher_grid,'linestyle','none','FaceAlpha',alph);
xl = xlabel('x','interpreter','latex','fontsize',50,'units','normalized','position',[0.060822413861088,0.244504540413467,0]);
yl = ylabel('y','interpreter','latex','fontsize',50,'units','normalized','position',[0.696385004626089,0.120144336220999,0]);
zl =zlabel('z','interpreter','latex','fontsize',50,'rotation',0,'verticalalignment','bottom','units','normalized','position',[-0.111389098034131,0.466520019834656,0]);
lighting none
clim([0.01 200])
set(gca,'colorscale','log')

%plot3([0 0],[0 0],[0 1],':k','linewidth',2);
%plot3([0 1],[0 0],[0 0],':k','linewidth',2);
%plot3([0 0],[0 1],[0 0],':k','linewidth',2);

arrow3d([0 0],[0 0],[0 1],0.85,0.025,2.*0.025,'k');
arrow3d([0 1],[0 0],[0 0],0.85,0.025,2.*0.025,'k');
arrow3d([0 0],[0 1],[0 0],0.85,0.025,2.*0.025,'k');

lighting none

plot3([-1 1],[0 0],[-rmax -rmax],'k','linewidth',2);
plot3([0 0],[-1 1],[-rmax -rmax],'k','linewidth',2);

hl_theta = plotAngleArc3d(1,[0 0 1],mu,[0 0 0],0.6,{'-r','LineWidth',2},'$\overline{\theta}_p$',{'interpreter','latex','fontsize',18,'Color','r'});
hl_phi = plotAngleArc3d(1,[1 0 0],[mu(1) mu(2) 0],[0 0 0],0.72,{'-r','LineWidth',2},'$\overline{\phi}_p$',{'interpreter','latex','fontsize',18,'Color','r'});

hl_phi_xy = plotAngleArc3d(1,[1 0 0],[mu(1) mu(2) 0],[0 0 -rmax],0.72,{'-r','LineWidth',2});

%plot3([0 (mu(1))],[0 mu(2)],[-rmax -rmax],'r','linewidth',2);

plot3([0 mu(1)],[0 mu(2)],[0 0],':r','linewidth',2);
plot3([mu(1) mu(1)],[mu(2) mu(2)],[0 mu(3)],':r','linewidth',2);

axy = arrow3d([0 (mu(1))],[0 mu(2)],[-rmax -rmax],0.85,0.025,2.*0.025,'r');

axy.LineWidth = 2;

 
lighting none

set(gca,'view',[68,26])

set(gca,'ticklabelinterpreter','latex','xticklabel','','yticklabel','','zticklabel','','units','normalized','linewidth',1.4,'ticklength',[0.02 0.04])
cbar = colorbar;
set(cbar,'ticklabelinterpreter','latex','fontsize',16,'ytick',[0.01 0.1 1.0 10 100],'yticklabel',{'0.01' '0.1' '1.0' '10' '100'},...
    'linewidth',1.4,'color',[0.3 0.3 0.3],'ticklength',0.03)
ylabel(cbar,'Probability Density','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')



set(gca,'position',[0.09947619047619,0.060492220379061,0.622874614170619,0.934031589144766])