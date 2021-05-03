pro test_base
tlb=widget_base(xsize=800,ysize=400,tlb_frame_attr=1,title='top level base')

button=widget_button(tlb,value='button',xsize=100,ysize=30,xoffset=600,yoffset=350)

base1=widget_base(tlb,xsize=300,ysize=350,xoffset=25,yoffset=25,frame=1)

base2=widget_base(tlb,xsize=425,ysize=300,xoffset=350,yoffset=25,frame=1)

draw=widget_draw(base1,xsize=280,ysize=340,xoffset=10,yoffset=5)


labelin=widget_label(base2,value='open input file',xoffset=10,yoffset=10)
textin=widget_text(base2,xsize=40,ysize=1,xoffset=10,yoffset=25,uname='txtin')
btnopen=widget_button(base2,value='open',xsize=70,ysize=25,xoffset=350,yoffset=25,uname='btin')

widget_control,tlb,/realize
widget_control,draw,get_value=win
widget_control,tlb,set_uvalue=win
xmanager,'test_base',tlb,/no_block
end

pro test_base_event,ev
textin=widget_info(ev.top,find_by_uname='txtin') ;找到文本框编号
uname=widget_info(ev.id,/uname);获取事件uname

case uname of
  'btin':begin
    filein=dialog_pickfile(/read,filter='*,jpg')
    widget_control,textin,set_value=filein
    pic=read_image(filein)
    display=bytarr(3,280,340)
    display[0,*,*]=congrid(reform(pic[0,*,*]),280,340)
    display[1,*,*]=congrid(reform(pic[1,*,*]),280,340)
    display[2,*,*]=congrid(reform(pic[2,*,*]),280,340)
    widget_control,ev.top,get_uvalue=win
    wset,win
    tvscl,display,/true
    end
endcase
end