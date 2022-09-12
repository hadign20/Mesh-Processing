classdef MeshHelper < handle
    methods(Static)
        
        function [p_min, p_max] = getBoundingBox(mesh)
            % Returns the points with minimal and maximal coordinates of the
            % smallest axis-aligned bounding box of the mesh.

            % TODO_A1 Task 1
            % 
            % Find the axis-aligned bounding box of the mesh and return its
            % minimal and maximal corner vertices. Use the vertex trait
            % 'position' to find them.
            
            %p_min = [0 0 0];
            %p_max = [0.2 0.2 0.2];
            
            %====================
            % first try
            %====================
%             points = mesh.getAllVertices();
%             all_vp = points.getTrait('position');
%             x_min = min(all_vp(:,1));
%             y_min = min(all_vp(:,2));
%             z_min = min(all_vp(:,3));
%             x_max = max(all_vp(:,1));
%             y_max = max(all_vp(:,2));
%             z_max = max(all_vp(:,3));
%             
%             p_min = [x_min y_min z_min];
%             p_max = [x_max y_max z_max];
            
            
            %====================
            % final
            %====================
            V = mesh.getAllVertices().getTrait('position');
            p_min = min(V);
            p_max = max(V);
        end
        
        
        function [V_start, V_end] = getBoundaryEdges(mesh)
            % Returns a list of line segments describing the boundary of
            % the mesh. Returns two nbe-by-3 arrays (nbe=number of
            % boundary edges), such that the i-th row of V_start and the
            % i-th row of V_end describe the two end points of the ith boundary
            % edge. The order of boundary edges is arbitrary.

            % TODO_A1 Task 2
            % 
            % Find all boundary edges of the mesh. You can achieve this by
            % finding all halfedges that do not have an incident face (i.e. its
            % face index equals zero). Make sure to test your
            % implementation for meshes with and without boundary.
            
            %V_start = zeros(0,3);
            %V_end = zeros(0,3);
            
            %====================
            % first try
            %====================
%             %get all the half-edges of the mesh
%             all_he = mesh.getAllHalfedges();
%             
%             %get all the faces corresponding to half-edges
%             all_he_f = all_he.face();
%             
%             %get all the indexes of those faces
%             all_he_f_i = all_he_f.index();
%             
%             %store half-edges the face index of which is 0
%             count =  sum(all_he_f_i(:)==0);
%             if count > 0
%                 all_b_he = mesh.getHalfedge(all_he.index(all_he_f_i == 0));
% 
%                 %get the starting and ending vertex of each of those half-edges
%                 f = all_b_he.from();
%                 t = all_b_he.to();
% 
%                 %return the position of boundary edges
%                 V_start = f.getTrait('position');
%                 V_end = t.getTrait('position');
%             
%             else
%                 V_start = zeros(0,3);
%                 V_end = zeros(0,3);
%             end
            
            %====================
            % final
            %====================
            he = mesh.getAllHalfedges();
            temp = he.index(he.face().index == 0);
            
            if ~isempty(temp)
                he_bdry = mesh.getHalfedge(temp);
                
                V_start = he_bdry.from().getTrait('position');
                V_end = he_bdry.to().getTrait('position');
                
            else
                V_start = zeros(0,3);
                V_end = zeros(0,3);
            end

        end
        
        
        function calculateFaceTraits(mesh)
            % Fills in a number of face traits in the TriangleMesh mesh.
            % Each face stores its surface area (trait 'area'), its
            % centroid, which is the arithmetic mean of its corner vertices
            % (trait 'centroid), and its normal (trait 'normal')

            % TODO_A1 Task 3
            % 
            % Fill in the face traits a) 'area', b) 'centroid', and  c) 'normal'.
            % 'area' is the surface area of a triangular face. 'centroid' is
            % the mean of the three corner vertices. 'normal' is the uniquely
            % defined outwards-facing normal of the face, given CCW winding of
            % the three corner vertices.
            
            %====================
            % first try
            %====================
%             %get all the faces of the mesh
%             faces = mesh.getAllFaces();
% 
%             %get half-edges corresponding to faces
%             hes = faces.halfedge();
%             
%             %get three vertices of faces
%             v1 = hes.from();
%             v2 = hes.to();
%             v3 = hes.next().to();
%             
%             %get the positions of the vertices
%             v1_pos = v1.getTrait('position');
%             v2_pos = v2.getTrait('position');
%             v3_pos = v3.getTrait('position');
%             
%             %=================== face area ================================
%             %calculate the area of faces given three points
%             x = [v1_pos(:,1) v2_pos(:,1) v3_pos(:,1)];
%             y = [v1_pos(:,2) v2_pos(:,2) v3_pos(:,2)];
%             z = [v1_pos(:,3) v2_pos(:,3) v3_pos(:,3)];
% %    
% %             area = bsxfun(@times, x(:,1), y(:,2))+ bsxfun(@times, x(:,2), y(:,3)) +...
% %                 bsxfun(@times, x(:,3), y(:,1))- bsxfun(@times, x(:,3), y(:,2)) -...
% %                 bsxfun(@times, x(:,2), y(:,1))- bsxfun(@times, x(:,1), y(:,3));
% 
%             %area = 0.5 * norm(cross(hes(,:) , hes.next()));
% %             nexts = hes.next();
% %             cr = arrayfun(@(x)cross(hes(x,:),nexts(x,:)),1:length(hes));
% %             area = 0.5 * norm(cr);
%             
% %             d1 = arrayfun(@(i)det([x(i,:);y(i,:);ones(1,3)]),1:length(x));
% %             d2 = arrayfun(@(i)det([x(i,:);z(i,:);ones(1,3)]),1:length(x));
% %             d3 = arrayfun(@(i)det([y(i,:);z(i,:);ones(1,3)]),1:length(y));
% 
%             d1 = x(:,1).*y(:,2)-x(:,2).*y(:,1)-x(:,1).*y(:,3)+x(:,3).*y(:,1)+x(:,2).*y(:,3)-x(:,3).*y(:,2);
%             d2 = x(:,1).*z(:,2)-x(:,2).*z(:,1)-x(:,1).*z(:,3)+x(:,3).*z(:,1)+x(:,2).*z(:,3)-x(:,3).*z(:,2);
%             d3 = y(:,1).*z(:,2)-y(:,2).*z(:,1)-y(:,1).*z(:,3)+y(:,3).*z(:,1)+y(:,2).*z(:,3)-y(:,3).*z(:,2);
%                        
%             area = 0.5*sqrt(d1.^2 + d2.^2 + d3.^2);
%             
%             faces.setTrait('area', area);
%             
%             %=================== face centroid ============================
%             
%             centroid = (v1_pos + v2_pos + v3_pos) / 3;
%             faces.setTrait('centroid' , centroid);
%             
%             %=================== face nomal ===============================
%             
%             vec1 = v2_pos - v1_pos;
%             vec2 = v3_pos - v1_pos;
%             f_normal = 100*cross(vec1,vec2); % mult by 100 to make the normal big
%             enough to be visible
%             faces.setTrait('normal',f_normal);

            %====================
            % final
            %====================
            f = mesh.getAllFaces();
            he = f.halfedge();
            v1 = he.from().getTrait('position');
            v2 = he.to().getTrait('position');
            v3 = he.next().to().getTrait('position');
            
            fn = cross(v2-v1 , v3-v1);
            area = sqrt(sum(fn.*fn , 2))/2;
            centroid = (v1+v2+v3)/3;
            
            f.setTrait('area', area);
            f.setTrait('centroid', centroid);
            f.setTrait('normal', normr(fn));
        end
        
        function calculateVertexTraits(mesh)
            % Computes the degree of each vertex and stores it in the
            % vertex trait 'degree'.
            v = mesh.getAllVertices();
            he1 = v.halfedge();
            he_current = he1.twin().next();
            degs = zeros(mesh.num_vertices,1);
            i=1;
            while any(degs==0)
                degs(degs==0 & he_current.index == he1.index) = i;
                he_current = he_current.twin().next();
                i = i+1;
            end
            v.setTrait('degree',degs);
        end
        
        
        function calculateHalfedgeTraits(mesh)
            % Computes the 'angle' halfedge trait, which gives the angle
            % between the halfedge and its previous halfedge in radians.
            
            % TODO_A1 Task 5a
            %
            % Calculate the angle between a halfedge and its previous halfedge.
            % Store the resulting angle in the halfedge trait 'angle'.
            
            he = mesh.getAllHalfedges();
            v1 = he.prev().from().getTrait('position') - he.from().getTrait('position');
            v2 = he.to().getTrait('position') - he.from().getTrait('position');
            
            % Angle in radians
            %angle = atan2(vecnorm(cross(v1,v2,2),2,2) , dot(v1,v2,2));
            angle = atan2(sqrt(sum(cross(v1,v2).^2,2)) , dot(v1,v2,2));
            he.setTrait('angle',angle);
        end
        
        
        function calculateVertexNormals(mesh, weighting)
            % Computes vertex normals as a weighted mean of face normals.
            % The parameter 'weighting' can be one of the following:
            % 'area': The face normal weights equal the face surface areas.
            % 'angle': The face normal weights equal the opening angle
            %    of the face at the vertex.
            % Store the results in the vertex trait 'normal'.
            if nargin<2
                weighting='area';
            end
            switch weighting
                case 'area'
                    % TODO_A1 Task 4
                    % 
                    % Fill in the 'area' branch of this function. Calculate
                    % the vertex normals as weighted averages of the
                    % adjacent face normals, where the weight is given by
                    % the surface area of the face. Don't forget to
                    % normalize!

                    he = mesh.getAllHalfedges();
                    he_ii = he.index(he.face().index ~= 0);
                    he_inner = mesh.getHalfedge(he_ii);
                    fe_normal = he_inner.face().getTrait('normal');
                    fe_area = he_inner.face().getTrait('area');
                    my_result =10* fe_area .* fe_normal;           
                    ve_normal = zeros(mesh.num_vertices, 3);
                    ve_ii = he_inner.from().index();
                    for i = 1:3
                        ve_normal(:,i) = accumarray(ve_ii , my_result(:,i));
                    end
                    mesh.getAllVertices().setTrait('normal', normr(ve_normal));
                    
                case 'angle'
                    % TODO_A1 Task 5b
                    %
                    % Fill in the 'angle' branch of this function.
                    % Calculate the vertex normals as weighted averages of
                    % the adjacent face normals, where the weight is given
                    % by the angle that the face confines at the vertex.
                    % Use the 'angle' halfedge trait computed in Task 5a for this.

                    he = mesh.getAllHalfedges();
                    he_ii = he.index(he.face().index ~= 0);
                    he_inner = mesh.getHalfedge(he_ii);
                    he_angle = he_inner.getTrait('angle');
                    fe_normal = he_inner.face().getTrait('normal');
                    my_result =  he_angle .* fe_normal;
                    ve_normal = zeros(mesh.num_vertices, 3);
                    ve_ii = he_inner.from().index();
                    for i = 1:3
                        ve_normal(:,i) = accumarray(ve_ii , my_result(:,i));
                    end
                    mesh.getAllVertices().setTrait('normal', normr(ve_normal));
            end
        end
    end
end