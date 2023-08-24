module top(
    input         clk,
    input         reset,
    input  [3:0]  row,
    output [3:0]  col,
    output        keyboard_en,
    output [15:0] keyboard_led,
    output [3:0]  keyboard_num
);

keyboard u_keyboard(
    .clk(clk), 
    .reset(reset), 
    .row(row), 
    .col(col), 
    .keyboard_en(keyboard_en), 
    .keyboard_led(keyboard_led),   //����DCBA#9630852*741��ӦGLD0-GLD7:YLD0-YLD7
    .keyboard_num(keyboard_num)    // ��ֻ��һ�����ڣ�ֱ���͵�led��ʾ������������
);

endmodule
