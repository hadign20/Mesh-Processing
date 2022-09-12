classdef MeshViewerUI < handle
    properties(Access=private)
        fig
        axes
        lights
        
        model_stats_text
        
        model_patch
        model_vertex_patch
        model_vn_patch
        model_fn_patch
        grid_patch
        boundary_patch
        bounding_box_patch
        
        normal_scale
        vertex_normal_weighting
        mesh
        last_file
    end
    
    properties(Access=private, Constant)
        edge_color = [0 0 0]
        vertex_color = [0 0 0]
        face_color = [0.6 0.6 1]
        bb_color = [0.4 0.4 0.4];
        grid_color = [0.7 0.7 0.7];
        boundary_color = [1 0.2 0.2];
        face_normal_color = [1 0 0.5];
        vertex_normal_color = [1 0.5 0];
        
        align_view_text = {'+X','-X','+Y','-Y','+Z','-Z'};
        align_view_angles = [-90 0;90 0;0 0;180 0;0 -90;0 90];
    end
    
    methods
        function obj = MeshViewerUI()
            obj.fig = figure('Name','Mesh Viewer',...
                'Visible','off','Position',[360,500,1200,600]);
            
            obj.axes = axes('Parent',obj.fig,'Units','pixels',...
                'Position',[30 30 540 540],'Units','normalized',...
                'DataAspectRatio',[1 1 1]);
            xlabel('x');
            ylabel('y');
            zlabel('z');
            
            hold on;
            
            light_angles = [-45 45; -135 45; 90 -30];
            for i=1:size(light_angles,1)
                obj.lights{i} = lightangle(light_angles(i,1), light_angles(i,2));
            end
            
            obj.model_patch = patch('Vertices',[],'Faces',[],...
                'EdgeColor',obj.edge_color,'FaceColor',obj.face_color,...
                'FaceLighting','none','SpecularStrength',0.5,'SpecularExponent',20);
            obj.model_vertex_patch = patch('Vertices',[],'Faces',[],...
                'MarkerFaceColor',obj.vertex_color,'MarkerSize',4,'Marker','o',...
                'MarkerEdgeColor','none','Visible','off');
            obj.grid_patch = patch('Vertices',[],'Faces',[],...
                'EdgeColor',obj.grid_color,'FaceColor','none');
            obj.bounding_box_patch = patch('Vertices',[],'Faces',[],...
                'EdgeColor',obj.bb_color,'FaceColor','none','LineWidth',1);
            obj.boundary_patch = patch('Vertices',[],'Faces',[],...
                'EdgeColor',obj.boundary_color,'FaceColor','none','LineWidth',2,...
                'Visible','off');
            obj.model_fn_patch = patch('Vertices',[],'Faces',[],...
                'EdgeColor',obj.face_normal_color,'FaceColor','none',...
                'LineWidth',1.5,'Visible','off');
            obj.model_vn_patch = patch('Vertices',[],'Faces',[],...
                'EdgeColor',obj.vertex_normal_color,'FaceColor','none',...
                'LineWidth',5,'Visible','off');
            
            % Model Stats
            obj.model_stats_text = uicontrol('Style','text','String','asdasd',...
                'Position',[0 582 200 20],'Units','normalized','HorizontalAlignment','left');
            
            % File Panel
            file_panel = uipanel(obj.fig,'Title','File','Units','pixels',...
                'Position',[700 540 490 56],'Units','normalized');
            uicontrol(file_panel,'Style','pushbutton','String','Load Model...',...
                'Position',[5 20 80 20],'Units','normalized','Callback',@obj.loadModelPressed);
            
            % View Panel
            view_panel = uipanel(obj.fig,'Title','View','Units','pixels',...
                'Position',[700 440 490 96],'Units','normalized');
            
            % V,E,F
            uicontrol(view_panel,'Style','checkbox','String','Vertices',...
                'Position',[5 64 60 20],'Units','normalized','Value',0,'Callback',@obj.viewOptionChanged);
            uicontrol(view_panel,'Style','checkbox','String','Edges',...
                'Position',[75 64 50 20],'Units','normalized','Value',1,'Callback',@obj.viewOptionChanged);
            uicontrol(view_panel,'Style','checkbox','String','Faces',...
                'Position',[135 64 60 20],'Units','normalized','Value',1,'Callback',@obj.viewOptionChanged);
            
            % Grid, BB, Boundary
            uicontrol(view_panel,'Style','checkbox','String','Grid',...
                'Position',[5 44 50 20],'Units','normalized','Value',1,'Callback',@obj.viewOptionChanged);
            uicontrol(view_panel,'Style','checkbox','String','Bounding Box',...
                'Position',[60 44 90 20],'Units','normalized','Value',1,'Callback',@obj.viewOptionChanged);
            uicontrol(view_panel,'Style','checkbox','String','Boundary',...
                'Position',[5 24 90 20],'Units','normalized','Value',0,'Callback',@obj.viewOptionChanged);
            
            % Normals
            uicontrol(view_panel,'Style','checkbox','String','Vertex Normals',...
                'Position',[240 64 100 20],'Units','normalized','Value',0,'Callback',@obj.viewOptionChanged);
            vn_type_group = uibuttongroup(view_panel,'BorderType','none',...
                'Units','pixels','Position',[350 64 200 20],'Units','normalized',...
                'SelectionChanged',@obj.vertexNormalWeightingChanged);
            uicontrol(vn_type_group, 'Style','radiobutton','String','area',...
                'Position',[0 0 50 20],'Units','normalized');
            uicontrol(vn_type_group, 'Style','radiobutton','String','angle',...
                'Position',[50 0 50 20],'units','normalized');
            obj.vertex_normal_weighting = 'area';
            
            uicontrol(view_panel,'Style','checkbox','String','Face Normals',...
                'Position',[240 44 100 20],'Units','normalized','Value',0,'Callback',@obj.viewOptionChanged);
            uicontrol(view_panel,'Style','text','String','Scale:',...
                'Position',[240 20 40 20],'Units','normalized','HorizontalAlignment','left');
            uicontrol(view_panel,'Style','slider','Min',-2,'Max',2,'SliderStep',[0.2/4 0.5/4],...
                'Position',[280 24 150 20],'Units','normalized','Value',0,'Callback',@obj.normalScaleChanged);
            obj.normal_scale = 0.04;
            
            % Align View
            uicontrol(view_panel,'Style','text','String','Align View',...
                'Position',[5 0 60 20],'Units','normalized','HorizontalAlignment','left');
            for i=1:6
                uicontrol(view_panel,'Style','pushbutton','String',obj.align_view_text{i},...
                    'Position',[65+(i-1)*30 2 25 20],'Units','normalized','UserData',i,...
                    'Callback',@obj.alignViewPressed);
            end
            
            % Shading Panel
            shading_panel = uipanel(obj.fig,'Title','Shading','Units','pixels',...
                'Position',[700 380 490 56],'Units','normalized');
            
            uicontrol(shading_panel,'Style','text','String','Type:',...
                'Position',[5 20 60 20],'Units','normalized','HorizontalAlignment','left');
            shading_type_group = uibuttongroup(shading_panel,'BorderType','none',...
                'Units','pixels','Position',[50 24 200 20],'Units','normalized',...
                'SelectionChanged',@obj.shadingTypeChanged);
            uicontrol(shading_type_group,'Style','radiobutton','String','none',...
                'Position',[0 0 50 20],'Units','normalized');
            uicontrol(shading_type_group,'Style','radiobutton','String','flat',...
                'Position',[50 0 50 20],'Units','normalized');
            uicontrol(shading_type_group,'Style','radiobutton','String','Gouraud',...
                'Position',[90 0 70 20],'Units','normalized');

            movegui(obj.fig,'center');
            obj.fig.Visible = 'on';
        end
        
        function alignViewPressed(obj,source,data)
            i = source.UserData;
            view(obj.align_view_angles(i,:));
        end
        
        function vertexNormalWeightingChanged(obj,source,data)
            obj.vertex_normal_weighting = data.NewValue.String;
            MeshHelper.calculateVertexNormals(obj.mesh, obj.vertex_normal_weighting);
            obj.updateVertexNormalModel();
        end
        
        function loadModelPressed(obj,source,data)
            filters = {'*.obj', 'OBJ Files (*.mat)';...
                '*.*', 'All Files (*.*)'};
            if isempty(obj.last_file)
                [filename, pathname] = uigetfile(filters, 'Load Model...');
            else
                [filename, pathname] = uigetfile(filters, 'Load Model...', obj.last_file);
            end
            if ~(isnumeric(filename) && isnumeric(pathname))
                obj.last_file = [pathname filename];
                obj.loadModel(obj.last_file);
            end
        end
        
        function shadingTypeChanged(obj,source,data)
            obj.model_patch.FaceLighting = data.NewValue.String;
        end
        
        function normalScaleChanged(obj,source,data)
            obj.normal_scale = 0.04*(3^source.Value);
            obj.updateFaceNormalModel();
            obj.updateVertexNormalModel();
        end
        
        function viewOptionChanged(obj, source, data)
            switch(source.String)
                case 'Vertices'
                    obj.model_vertex_patch.Visible = val2vis(source.Value);
                case 'Edges'
                    if source.Value==1
                        obj.model_patch.EdgeColor = obj.edge_color;
                    else
                        obj.model_patch.EdgeColor = 'none';
                    end
                case 'Faces'
                    if source.Value==1
                        obj.model_patch.FaceColor = obj.face_color;
                    else
                        obj.model_patch.FaceColor = 'none';
                    end
                case 'Vertex Normals'
                    obj.model_vn_patch.Visible = val2vis(source.Value);
                case 'Face Normals'
                    obj.model_fn_patch.Visible = val2vis(source.Value);
                case 'Grid'
                    obj.grid_patch.Visible = val2vis(source.Value);
                case 'Bounding Box'
                    obj.bounding_box_patch.Visible = val2vis(source.Value);
                case 'Boundary'
                    obj.boundary_patch.Visible = val2vis(source.Value);
                otherwise
            end
        end
        
        function loadModel(obj, filename)
            obj.mesh = ModelLoader.loadOBJ(filename);
            
            obj.updateAxes();
            obj.updateModelStats();
            
            MeshHelper.calculateFaceTraits(obj.mesh);
            MeshHelper.calculateVertexTraits(obj.mesh);
            MeshHelper.calculateHalfedgeTraits(obj.mesh);
            
            MeshHelper.calculateVertexNormals(obj.mesh, obj.vertex_normal_weighting);
            
            obj.updateGridModel();
            obj.updateBoundingBoxModel();
            obj.updateBoundaryModel();
            obj.updateFaceNormalModel();
            obj.updateVertexNormalModel();
        end
        
        function updateModelStats(obj)
            nv = obj.mesh.num_vertices;
            ne = obj.mesh.num_edges;
            nf = obj.mesh.num_faces;
            
            obj.model_stats_text.String = sprintf(...
                ' v %i e %i f %i',nv,ne,nf);
        end
        
        function updateAxes(obj)
            [V,F] = obj.mesh.toFaceVertexMesh();
            
            obj.model_patch.Vertices = V;
            obj.model_patch.Faces = F;
            
            obj.model_vertex_patch.Vertices = V;
            obj.model_vertex_patch.Faces = (1:obj.mesh.num_vertices)';
            
            pmin = min(V,[],1);
            pmax = max(V,[],1);
            
            view_offset = max(0.1*(pmax-pmin));
            view_min = pmin - view_offset;
            view_max = pmax + view_offset;
            
            axis vis3d;
            
            view(-60,30);
            zoom out;
            zoom(0.7);
            
            xlim([view_min(1) view_max(1)]);
            ylim([view_min(2) view_max(2)]);
            zlim([view_min(3) view_max(3)]);
        end
        
        function updateGridModel(obj)
            r = max([obj.axes.XLim(2)-obj.axes.XLim(1)...
                obj.axes.YLim(2)-obj.axes.YLim(1)]);
            step = 10^round(log(r/10)/log(10));
            x_ticks = ((ceil(obj.axes.XLim(1)/step)*step):step:(floor(obj.axes.XLim(2)/step)*step))';
            y_ticks = ((ceil(obj.axes.YLim(1)/step)*step):step:(floor(obj.axes.YLim(2)/step)*step))';
            v1 = [kron(x_ticks,[1;1]) repmat(obj.axes.YLim(:),length(x_ticks),1)];
            v2 = [repmat(obj.axes.XLim(:),length(y_ticks),1) kron(y_ticks,[1;1])];
            
            obj.grid_patch.Vertices = [[v1;v2] zeros(2*(length(x_ticks)+length(y_ticks)),1)];
            obj.grid_patch.Faces = reshape(1:size(obj.grid_patch.Vertices,1),2,[])';
        end
        
        function updateBoundingBoxModel(obj)
            if isempty(obj.mesh)
                return;
            end
            [p_min, p_max] = MeshHelper.getBoundingBox(obj.mesh);
            [V,E] = GeometryHelper.buildBoxEdges(p_min,p_max);
            
            obj.bounding_box_patch.Vertices = V;
            obj.bounding_box_patch.Faces = E;
        end
        
        function updateBoundaryModel(obj)
            [V_start, V_end] = MeshHelper.getBoundaryEdges(obj.mesh);
            
            obj.boundary_patch.Vertices = reshape([V_start'; V_end'],3,[])';
            obj.boundary_patch.Faces = reshape(1:size(obj.boundary_patch.Vertices,1),2,[])';
        end
        
        function updateFaceNormalModel(obj)
            if ~isfield(obj.mesh.F_traits, 'normal') || ...
                    ~isfield(obj.mesh.F_traits, 'centroid')
                obj.model_fn_patch.Vertices = [];
                obj.model_fn_patch.Faces = [];
                return;
            end
            
            f = obj.mesh.getAllFaces();
            v1 = f.getTrait('centroid');
            v2 = v1 + f.getTrait('normal')*obj.normal_scale;
            
            obj.model_fn_patch.Vertices = reshape([v1'; v2'],3,[])';
            obj.model_fn_patch.Faces = reshape(1:size(obj.model_fn_patch.Vertices,1),2,[])';
        end
        
        function updateVertexNormalModel(obj)
            if ~isfield(obj.mesh.V_traits, 'normal')
                obj.model_vn_patch.Vertices = [];
                obj.model_vn_patch.Faces = [];
                return;
            end
            
            v = obj.mesh.getAllVertices();
            v1 = v.getTrait('position');
            v2 = v1 + v.getTrait('normal')*obj.normal_scale;
            
            obj.model_vn_patch.Vertices = reshape([v1'; v2'],3,[])';
            obj.model_vn_patch.Faces = reshape(1:size(obj.model_vn_patch.Vertices,1),2,[])';
        end
    end
end