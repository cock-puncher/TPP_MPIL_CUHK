classdef Tree
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        ptr_map;
        max_key;
    end
    
    methods
        function obj = Tree()
            obj.ptr_map = containers.Map;
            root = containers.Map({'parent', 'data', 'children', 'depth'}, {[], [], [], 1});
            obj.ptr_map('1') = root;
            obj.max_key = 1;
        end
        
        function [obj, ptr] = add_leaf(obj, data, parent_ptr)
            parent_ptr = num2str(parent_ptr);
            if ~isKey(obj.ptr_map, parent_ptr)
                ptr = -1;
                return;
            end
            obj.max_key = obj.max_key + 1;
            ptr = obj.max_key;
            parent = obj.ptr_map(parent_ptr);
            parent('children') = [parent('children'), ptr];
            node = containers.Map({'parent', 'data', 'children', 'depth'}, ...
                {parent_ptr, data, [], parent('depth') + 1});
            obj.ptr_map(num2str(ptr)) = node; 
        end
        
        function flag = is_in(obj, ptr)
            ptr = num2str(ptr);
            if ~isKey(obj.ptr_map, ptr)
                flag = 0;
            else
                flag = 1;
            end
        end
        
        function [obj, success] = remove(obj, ptr)
            ptr = num2str(ptr);
            if ~isKey(obj.ptr_map, ptr)
                success = 0;
            else
                temp = obj.ptr_map(ptr);
                temp = obj.ptr_map(num2str(temp('parent')));
                a = temp('children');
                a(a == str2num(ptr)) = [];
                temp('children') = a;
                obj.ptr_map.remove(ptr);
                success = 1;
            end
        end
        
        function [obj, success] = modify(obj, ptr, str, new)
            ptr = num2str(ptr);
            if ~isKey(obj.ptr_map, ptr)
                success = 0;
            else
                if strcmp(str, 'children') || strcmp(str, 'data') ...
                        || strcmp(str, 'depth') || strcmp(str, 'parent')
                    k = obj.ptr_map(ptr);
                    k(str) = new;
                    success = 1;
                else
                    success = 0;
                end
            end
        end
        
        function depth = get_depth(obj, ptr)
            ptr = num2str(ptr);
            if ~isKey(obj.ptr_map, ptr)
                depth = -1;
            else
                depth = obj.ptr_map(ptr);
                depth = depth('depth');
            end
        end
        
        function data = get_data(obj, ptr)
            ptr = num2str(ptr);
            if ~isKey(obj.ptr_map, ptr)
                data = [];
            else
                data = obj.ptr_map(ptr);
                data = data('data');
            end
        end
        
        function parent = get_parent(obj, ptr)
            ptr = num2str(ptr);
            if ~isKey(obj.ptr_map, ptr)
                parent = [];
            else
                parent = obj.ptr_map(ptr);
                parent = parent('parent');
            end
        end
        
        function children = get_children(obj, ptr)
            ptr = num2str(ptr);
            if ~isKey(obj.ptr_map, ptr)
                children = [];
            else
                children = obj.ptr_map(ptr);
                children = children('children');
            end
        end
    end
end

