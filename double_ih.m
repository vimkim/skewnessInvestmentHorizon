
function sum_ret = double_ih(ret) % two-fold increase of investment horizon
    
        sum_ret = ret(1:2:end-1) + ret(2:2:end); % loss of last data if ret is odd length
    
end
