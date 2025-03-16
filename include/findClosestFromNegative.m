function [closestValue, closestIndex] = findClosestFromNegative(A, target)
    % 确保输入的数组A是升序排列
    if ~issorted(A)
        A = sort(A);
    end
    
    % 初始化指针
    left = 1;
    right = length(A);
    closest = inf; % 使用无穷大作为初始最近距离
    closestIndex = -1;

    % 使用二分查找法进行搜索
    while left <= right
        mid = floor((left + right) / 2);
        
        if A(mid) < target
            % 如果当前元素小于目标值，检查是否比之前找到的更接近
            if target - A(mid) < closest
                closest = target - A(mid);
                closestValue = A(mid);
                closestIndex = mid;
            end
            left = mid + 1; % 因为需要找从负方向最近的数，所以向右查找
        else
            % 如果当前元素大于等于目标值，向左查找
            if right == mid || A(mid) == target
                closestValue = A(mid);
                closestIndex = mid;
                break; % 找到目标值或者数组的边界
            elseif A(mid) - target < closest
                closest = A(mid) - target;
                closestValue = A(mid);
                closestIndex = mid;
            end
            right = mid - 1;
        end
    end
    
    % 如果没有找到比目标值小的数，说明目标值小于数组中的所有数
    if closestIndex == -1
        closestValue = A(1);
        closestIndex = 1;
    end
end