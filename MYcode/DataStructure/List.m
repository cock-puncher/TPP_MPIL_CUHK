classdef List
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        data_table;
        link_table;
        len;
    end
    
    methods
        function obj = List(data)
            obj.len = size(data, 2);
            obj.data_table = data;
            obj.link_table = -1 * ones(2, obj.len + 2);
            % head element
            obj.link_table(1, 1) = 0;
            obj.link_table(2, 1) = 2;
            % tail element
            obj.link_table(1, 2) = 1;
            obj.link_table(2, 2) = 0;
        end
        
        function  [success, obj] = remove(obj, index)
            index = index + 2;
            if index < 1 || sum(obj.link_table(:, index) > [0,0]') <= 1
                success = false;
            else
                obj.link_table(2, obj.link_table(1, index)) = obj.link_table(2, index);
                obj.link_table(1, obj.link_table(2, index)) = obj.link_table(1, index);
                obj.link_table(1, index) = -1;
                obj.link_table(2, index) = -1;
                success = true;
            end
        end
        
        function  [success, obj] = add_tail(obj, index)
            index = index + 2;
            if index < 1 || sum(obj.link_table(:, index) > [0,0]') >= 1
                success = false;
            else
                obj.link_table(1, index) = obj.link_table(1, 2);
                obj.link_table(2, index) = 2;
                obj.link_table(2, obj.link_table(1, 2)) = index;
                obj.link_table(1, 2) = index;
                success = true;
            end
        end
        
        function  success = is_in(obj, index)
            if index < 1 || obj.link_table(1,index + 2) <0
                success = false;
            else
                success = true;
            end
        end
        
        function  success = is_empty(obj)
            if obj.link_table(2, 1) == 2
                success = true;
            else
                success = false;
            end
        end
        
        function  obj = add_all(obj)
            if obj.len >= 1
                for i = 3:obj.len+2
                    obj.link_table(1, i) = i - 1;
                    obj.link_table(2, i) = i + 1;
                end
                obj.link_table(2, 1) = 3;
                obj.link_table(1, 2) = obj.len + 2;
                obj.link_table(1, 3) = 1;
                obj.link_table(2, obj.len + 2) = 2;
            end
        end
        
        function  next = get_next(obj, index)
            index = index + 2;
            next = obj.link_table(2, index);
            if next > 2
                next = next - 2;
            else
                next = -1;
            end
        end
        
        function  [dir, next] = walk(obj, index, i)
            index = index + 2;
            if i ~= 0 
                next = obj.link_table(i, index);
                if next > 2
                    next = next - 2;
                    dir = i;
                else
                    next = index - 2;
                    dir = 0;
                end
            else
                next = obj.link_table(1, index);
                if next > 2
                    next = next - 2;
                    dir = 1;
                elseif obj.link_table(2, index) > 2
                    next = obj.link_table(2, index) - 2;
                    dir = 2;
                else
                    next = index - 2;
                    dir = 0;
                end
            end
        end
        
        function  [result, varargout] = traverse(obj, fun, varargin)
            temp_pos = obj.link_table(2, 1);
            loop_num = 1;
            while temp_pos ~= 2
                val = fun(obj.data_table(:, temp_pos - 2), varargin{1:nargin-2});
                if isempty(val) == false
                    if loop_num == 1
                        result = zeros(length(val'), obj.len);
                        if nargout > 1
                            varargout{1} = zeros(length(val'), obj.len);
                        end
                    end
                    result(:,loop_num) = val;
                    if nargout > 1
                        varargout{1}(:,loop_num) = temp_pos - 2;
                    end
                    loop_num = loop_num + 1;
                end
                temp_pos = obj.link_table(2, temp_pos);
            end
            if loop_num ~= 1
                result = result(:, 1:loop_num-1);
                if nargout > 1
                    varargout{1} = varargout{1}(:,1:loop_num-1);
                end
            else
                result = [];
            end
        end
    end
end

