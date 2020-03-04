clear
clc

global AeroSQL_explorer Airfoils

%% Conex�o com o banco de dados

conn = database('AeroSQLDB_MySQL_Reader','Reader','');

%% Obtendo Tabela Airfoils

Airfoils = fetch(conn,"SELECT * FROM Airfoils;");

%% Criando UI

% Janela Principal
AeroSQL_explorer.main_figure = uifigure();
AeroSQL_explorer.main_figure.Name = 'AeroSQL Database Explorer';
AeroSQL_explorer.main_figure.Position = [400 350 1100 700];

% Listbox com perfis dispon�veis
AeroSQL_explorer.Perfis_listbox = uilistbox(AeroSQL_explorer.main_figure,'Items',Airfoils.Name,'ItemsData',1:length(Airfoils.Name));
AeroSQL_explorer.Perfis_listbox.Position = [20 AeroSQL_explorer.main_figure.Position(4)-280 300 250];
AeroSQL_explorer.Perfis_listbox.Tag = "perfis disponiveis";
AeroSQL_explorer.Perfis_listbox.ValueChangedFcn = @(listbox,event) muda_lista(listbox,conn,event);

% Label indicando o que se trata a listbox
AeroSQL_explorer.label_Perfis_disp = uilabel(AeroSQL_explorer.main_figure,'Text','Perfis Dispon�veis','Position',[20 AeroSQL_explorer.Perfis_listbox.Position(2)+AeroSQL_explorer.Perfis_listbox.Position(4)-5 100 25]);

% TabGroup Para disponibilizar informa��es do perfil
AeroSQL_explorer.Perfis_tabgroup = uitabgroup(AeroSQL_explorer.main_figure);
AeroSQL_explorer.Perfis_tabgroup.Position([3 4]) = [700 AeroSQL_explorer.main_figure.Position(4)-20];
AeroSQL_explorer.Perfis_tabgroup.Position([1 2]) = [AeroSQL_explorer.main_figure.Position(3)-AeroSQL_explorer.Perfis_tabgroup.Position(3)-20 10];

% Tabs que vivem neste TabGroup
AeroSQL_explorer.tab_geometria = uitab(AeroSQL_explorer.Perfis_tabgroup,'Title','Geometria');
AeroSQL_explorer.tab_coeficientes = uitab(AeroSQL_explorer.Perfis_tabgroup,'Title','Coeficientes');

% ---------------------------------------------------------------------- Axes ---------------------------------------------------------------------------------

% Axes do Tab Geometria
AeroSQL_explorer.axes_geometria = uiaxes(AeroSQL_explorer.tab_geometria);
AeroSQL_explorer.axes_geometria.Position = [10 10 680 AeroSQL_explorer.main_figure.Position(4)-70];
grid(AeroSQL_explorer.axes_geometria,'minor')
axis(AeroSQL_explorer.axes_geometria,'equal')

% Axes do Tab Coeficientes
AeroSQL_explorer.axes_coeficientes = uiaxes(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.axes_coeficientes.Position = [10 10 680 AeroSQL_explorer.main_figure.Position(4)-60];
grid(AeroSQL_explorer.axes_coeficientes,'minor')

% ----------------------------------------------------------------- Dropdowns ---------------------------------------------------------------------------------

AeroSQL_explorer.dropdown_Source = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_Source.Position = [AeroSQL_explorer.tab_coeficientes.Position(3)-500 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_Source.Tag = "Source";
AeroSQL_explorer.dropdown_Source.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_n_crit = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_n_crit.Position = [AeroSQL_explorer.dropdown_Source.Position(1)+AeroSQL_explorer.dropdown_Source.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_n_crit.Tag = "n_crit";
AeroSQL_explorer.dropdown_n_crit.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_Mach = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_Mach.Position = [AeroSQL_explorer.dropdown_n_crit.Position(1)+AeroSQL_explorer.dropdown_n_crit.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_Mach.Tag = "Mach";
AeroSQL_explorer.dropdown_Mach.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_Reynolds = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_Reynolds.Position = [AeroSQL_explorer.dropdown_Mach.Position(1)+AeroSQL_explorer.dropdown_Mach.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_Reynolds.Tag = "Reynolds";
AeroSQL_explorer.dropdown_Reynolds.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_coeficiente = uidropdown(AeroSQL_explorer.tab_coeficientes,'Items',["Cl","Cd","Cm"],'ItemsData',["Cl","Cd","Cm"]);
AeroSQL_explorer.dropdown_coeficiente.Position = [AeroSQL_explorer.dropdown_Reynolds.Position(1)+AeroSQL_explorer.dropdown_Reynolds.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_coeficiente.Tag = "Coeficiente";
AeroSQL_explorer.dropdown_coeficiente.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

%% Fun��es

function muda_lista(listbox,conn,event)

global AeroSQL_explorer Airfoils Polares

if listbox.Tag == "perfis disponiveis"
	
	AeroSQL_explorer.aux_Perfil = event.Value;
	
	%% Obtendo Geometria do perfil selecionado
	
	geometria_perfil = fetch(conn,sprintf("SELECT X,Y,Side FROM Geometries WHERE AirfoilID = %u;", Airfoils.AirfoilID(event.Value)));
	plot(AeroSQL_explorer.axes_geometria, geometria_perfil.X, geometria_perfil.Y)
	text(AeroSQL_explorer.axes_geometria,0.5,0.9,Airfoils.Name{listbox.Value},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
	%% Obtendo Dados dos Runs
	
	Polares = Estrutura_Polares(conn, Airfoils.AirfoilID(event.Value));
	
	AeroSQL_explorer.dropdown_Source.Items = Polares.Source.Value;
	AeroSQL_explorer.dropdown_Source.ItemsData = 1:length(Polares.Source.Value);
	AeroSQL_explorer.aux_Source = 1;
	
	AeroSQL_explorer.dropdown_n_crit.Items = string(Polares.Source.n_crit(1).Value);
	AeroSQL_explorer.dropdown_n_crit.ItemsData = 1:length(Polares.Source.n_crit(1).Value);
	AeroSQL_explorer.aux_n_crit = 1;
	
	AeroSQL_explorer.dropdown_Mach.Items = string(Polares.Source.n_crit(1).Mach(1).Value);
	AeroSQL_explorer.dropdown_Mach.ItemsData = 1:length(Polares.Source.n_crit(1).Mach(1).Value);
	AeroSQL_explorer.aux_Mach = 1;
	
	AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(1).Mach(1).Reynolds(1).Value);
	AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(1).Mach(1).Reynolds(1).Value);
	AeroSQL_explorer.aux_Reynolds = 1;
	
		
	plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(1).Mach(1).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(1).Mach(1).Reynolds(1).Polar(1).Value.Cl);
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name{listbox.Value},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
	
	axis(AeroSQL_explorer.axes_coeficientes,[-25 30 -2 2.2]);
	
end

end

function Seleciona_dropdown(dropdown,event)

global AeroSQL_explorer Polares Airfoils

if dropdown.Tag == "Source"
	
	AeroSQL_explorer.aux_Source = event.Value;
	
	AeroSQL_explorer.dropdown_n_crit.Items = string(Polares.Source.n_crit(event.Value).Value);
	AeroSQL_explorer.dropdown_n_crit.ItemsData = 1:length(Polares.Source.n_crit(event.Value).Value);
	
	AeroSQL_explorer.dropdown_Mach.Items = string(Polares.Source.n_crit(event.Value).Mach(1).Value);
	AeroSQL_explorer.dropdown_Mach.ItemsData = 1:length(Polares.Source.n_crit(event.Value).Mach(1).Value);
	
	AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Value);
	AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Value);
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Polar(1).Value.Cl);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Polar(1).Value.Cd);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(event.Value).Mach(1).Reynolds(1).Polar(1).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name{AeroSQL_explorer.aux_Perfil},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
		
elseif dropdown.Tag == "n_crit"
	
	AeroSQL_explorer.aux_n_crit = event.Value;
	
	AeroSQL_explorer.dropdown_Mach.Items = string(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Value);
	AeroSQL_explorer.dropdown_Mach.ItemsData = 1:length(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Value);
	
	AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Value);
	AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Value);
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Polar(1).Value.Cl);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Polar(1).Value.Cd);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Polar(1).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name{AeroSQL_explorer.aux_Perfil},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
elseif dropdown.Tag == "Mach"
	
	AeroSQL_explorer.aux_Mach = event.Value;
	
	AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Value);
	AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Value);
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(1).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(1).Value.Cl);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(1).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(1).Value.Cd);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(1).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(1).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name{AeroSQL_explorer.aux_Perfil},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
elseif dropdown.Tag == "Reynolds"
	
	AeroSQL_explorer.aux_Reynolds = event.Value;
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Cl);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Cd);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name{AeroSQL_explorer.aux_Perfil},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')

elseif dropdown.Tag == "Coeficiente"
	
	AeroSQL_explorer.aux_Coeficiente = event.Value;
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Cl);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Cd);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name{AeroSQL_explorer.aux_Perfil},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
end

end

function Polares = Estrutura_Polares(conn,AirfoilID)

Runs = fetch(conn,sprintf("SELECT * FROM Runs WHERE AirfoilID = %u",AirfoilID));
Raw_Polares = fetch(conn,sprintf("SELECT * FROM Polars WHERE AirfoilID = %u",AirfoilID));

u_Source = unique(Runs.Source);
u_Source = flip(u_Source);

for i_Source = 1:length(u_Source)
	Polares.Source.Value(i_Source) = string(u_Source{i_Source});
	Runs_Source = Runs(ismember(Runs.Source,u_Source{i_Source}),:);
	u_n_crit = unique(Runs_Source.Ncrit);
	
	for i_Ncrit = 1:length(u_n_crit)
		Polares.Source.n_crit(i_Source).Value(i_Ncrit) = u_n_crit(i_Ncrit);
		Runs_Ncrit = Runs_Source(ismember(Runs_Source.Ncrit,u_n_crit(i_Ncrit)),:);
		u_Mach = unique(Runs_Ncrit.Mach);
		
		for i_Mach = 1:length(u_Mach)
			Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Value(i_Mach) = u_Mach(i_Mach);
			Runs_Mach = Runs_Ncrit(ismember(Runs_Ncrit.Mach,u_Mach(i_Mach)),:);
			[u_Reynolds,ia_u_Reynolds] = unique(Runs_Mach.Reynolds);
			
			for i_Re = 1:length(u_Reynolds)
				Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Reynolds(i_Mach).Value(i_Re) = u_Reynolds(i_Re);
				
				Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Reynolds(i_Mach).Polar(i_Re).Value = Raw_Polares(ismember(Raw_Polares.RunID,Runs_Mach.RunID(ia_u_Reynolds(i_Re))),:);
			
			end
			
		end
		
	end
	
end

end

