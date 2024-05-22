`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2024 14:19:46
// Design Name: 
// Module Name: fixed_point_mul_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fixed_point_mul_test();
    
        reg [15:0] a;
        
        reg [15:0] b;
        
        wire  [15:0] res;
        
        reg sign;
        
        wire underflow;
        
        wire overflow;
        
        fixed_point_mul uut(a,sign,b,res,overflow,underflow);
        
        initial begin
        
        repeat(40)
            begin
                #5;
                a=$random;
                b=$random;
                sign=1;
            
            end
            
            #5
            a=5'b11111;
            b=5'b11111;
            sign=1;
            
            #100;
            
            $finish;
        
        
        end
        
    
endmodule



module fixed_point_mul#(parameter i_p1=2,f_p1=14,i_p2=2,f_p2=14,res_i_p=2,res_f_p=14)(
    input [i_p1+f_p1-1:0] a,
    input sign,
    input [i_p2+f_p2-1:0] b,
    output reg [res_i_p+res_f_p-1:0] result, 
    output reg overflow,
    output  reg  underflow
    );
    
    localparam ip1=2*i_p1;
    localparam fp1=2*f_p1;
    
//storing signed values for signed artithemic additon    
    reg signed  [i_p1+f_p1-1:0] temp_a;
    
    reg signed [i_p1+f_p1-1:0] temp_b; 
    
    //storing unsigned values for unsigned arithemetic
    
       reg   [i_p1+f_p1-1:0] temp_a_us;
    
    reg  [i_p1+f_p1-1:0] temp_b_us; 
    
//result of signed operation
    
    reg signed [(ip1+fp1)-1:0] res;
    
    reg signed [(ip1+fp1)-1:0] res_for_overflow; //converted the negetive result to positive using 2's complement

//result of unsigned operation
        reg  [(ip1+fp1)-1:0] res_unsigned;
        
        //temporary register for storing acutal result'
       
       reg [res_i_p+res_f_p-1:0] resultt;
       
       
       
       
       always@(*)
            res_for_overflow= (~res)+1'b1;
       



    always@(*)
        begin
            temp_a=a;
            temp_a_us=a;
            
            case(sign)
                1'b0:begin
                    temp_b_us=0;
                    temp_b_us=b<<(f_p1-f_p2);
                    end
                1'b1:begin
                    if(f_p1!=f_p2)
                        begin
                      temp_b[f_p1-(f_p2+1):0]={(f_p1-f_p2){1'b0}};
                      temp_b[f_p1-1:(f_p1-f_p2)]=b[f_p2-1:0];
                      temp_b[(f_p1+i_p2-1):f_p1]=b[i_p2+f_p2-1:f_p2];
                      temp_b[f_p1+i_p1-1:(f_p1+i_p1-1)-(i_p1-i_p2-1)]={(i_p1-i_p2){b[i_p2+f_p2-1]}};
                      end
                   else
                       begin
                       temp_b=b;
                       
                       end
                        
                     end   
            endcase               
        end 
        
   always@(*)
    begin
        if(sign)
                res = temp_a*temp_b;
        else
                res_unsigned=temp_a_us*temp_b_us;        
    end 
    
  
    always@(*)
        begin
        
        
        case(sign)
           1'b0:begin
             resultt[res_i_p+res_f_p-1:res_f_p]=0; 
             resultt[res_i_p+res_f_p-1:res_f_p]=res_unsigned[ip1+fp1-1:fp1];
             if(res_f_p > fp1)
                begin
                    resultt[res_f_p-1:0]={res_unsigned[fp1-1:0],{res_f_p-fp1{1'b0}}};   
                   
                end
             else if(res_f_p < fp1)
                begin
                    resultt[res_f_p-1:0]=res_unsigned[fp1-1:(fp1-res_f_p)];
                    
                end
            else
                begin
                    resultt[res_f_p-1:0]=res_unsigned[fp1-1:0];
                
                end    
                
             end
             
         1'b1:begin
         
                if(res_i_p>i_p1)
                    begin
                        resultt[res_f_p+i_p1-1:res_f_p]= res[ip1+fp1-1:fp1];
                        
                        resultt[res_f_p+res_i_p-1:res_f_p+i_p1]={(res_i_p-i_p1){res[ip1+fp1-1]}};
                    
                    end
                else
                    begin
                     resultt[res_i_p+res_f_p-1:res_f_p]=res[ip1+fp1-1:fp1];
                     
                    end    
         
                 if(res_f_p>fp1)
                begin
                    resultt[res_f_p-1:0]={res[fp1-1:0],{res_f_p-fp1{1'b0}}};  //-1 is there previously
                   
                end
            else if(res_f_p<fp1)
                begin
                    resultt[res_f_p-1:0]=res[fp1-1:(fp1-res_f_p)];
                    

                    
                end
            else
                begin
                    resultt[res_f_p-1:0]=res[fp1-1:0];
                
                end    
                
             end
                
                
              
       endcase                
                
        end
        
        
        
        
        
        
       always@(*)
            begin
            
                case(sign)
                    1'b0:begin
                            if(res_i_p > ip1)
                                   overflow=0;
                            else if(res_i_p<ip1)
                                begin   
                                     overflow = |(res_unsigned[(ip1+fp1)-1:(ip1+fp1)-(ip1-res_i_p)]);
                                 end
                           else
                                overflow=0;
                          end
                    1'b1:begin
                            if(res_i_p > i_p1)
                                   overflow=0;
                            else if( (~temp_a[i_p1+f_p1-1] && ~temp_b[i_p1+f_p1-1]) | ( temp_a[i_p1+f_p1-1] && temp_b[i_p1+f_p1-1]))
                                    overflow=(|(res[(ip1+fp1)-1:(ip1+fp1)-(ip1-res_i_p)])) | (resultt[res_f_p+res_i_p-1]);
                            else if( (~temp_a[i_p1+f_p1-1] && temp_b[i_p1+f_p1-1]) | ( temp_a[i_p1+f_p1-1] && ~temp_b[i_p1+f_p1-1]))
                                    overflow=((|(res_for_overflow[(ip1+fp1)-1:(ip1+fp1)-(ip1-res_i_p)])))|(~(resultt[res_f_p+res_i_p-1]));
                            else
                                    overflow=0;         
                         end
                endcase
           end
    
    
    
      always@(*)
            begin
            if(res_f_p<fp1)
                                begin
                                    underflow=  (|temp_a) &&(|temp_b) && (~|resultt);
                                end
                            else
                                begin
                                    underflow=0;
                                end        
                   
                           
            
            end
            
            
            always@(*)
                begin
                    case(sign)
                        1'b0:begin
                                if(overflow==1'b1)
                                    result={(res_i_p+res_f_p){1'b1}};
                                else if(underflow==1)
                                     result={{(res_i_p+res_f_p-1){1'b0}},1'b1};
                                else
                                    result=resultt;    
                                    
                               end
                        1'b1:begin
                                if((overflow==1'b1) && (~temp_a[i_p1+f_p1-1] && ~temp_b[i_p1+f_p1-1]) | ( temp_a[i_p1+f_p1-1] && temp_b[i_p1+f_p1-1]) )
                                        result={1'b0,{(res_i_p+res_f_p-1){1'b1}}};
                               else if((overflow==1'b1) &&  (temp_a[i_p1+f_p1-1] && ~temp_b[i_p1+f_p1-1]) | ( ~temp_a[i_p1+f_p1-1] && temp_b[i_p1+f_p1-1]) )
                                        result={1'b1,{(res_i_p+res_f_p-1){1'b0}}};
                               else if(underflow==1'b1 && (temp_a[i_p1+f_p1-1] && ~temp_b[i_p1+f_p1-1]) | ( ~temp_a[i_p1+f_p1-1] && temp_b[i_p1+f_p1-1])  )
                                        result={(res_i_p+res_f_p){1'b1}};
                               else if(underflow==1'b1 && (~temp_a[i_p1+f_p1-1] && ~temp_b[i_p1+f_p1-1]) | ( temp_a[i_p1+f_p1-1] && temp_b[i_p1+f_p1-1])  )
                                        result={{(res_i_p+res_f_p-1){1'b0}},1'b1};
                              else
                                        result=resultt;         
                                        
                             end 
                   endcase                   
                               
                
                end  
                
                
                
            
            

    
    
endmodule

