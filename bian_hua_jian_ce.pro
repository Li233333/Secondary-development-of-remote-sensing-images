;本程序用于计算变化向量和变化强度
;并且通过计算阈值，得出变化特征点，令大于阈值的就是本身，小于阈值的，置零
;
pro bian_hua_jian_ce
  tlb=widget_base(xsize=830,ysize=450,tlb_frame_attr=1,title='bian_hua_jian_ce')
  ;定义显示框和说明文本
  labelin=widget_label(tlb,value='tu_xiang_yu_lan',xoffset=25,yoffset=5)
  draw=widget_draw(tlb,xsize=400,ysize=400,xoffset=25,yoffset=30) 
  ;输入框1
  labelin=widget_label(tlb,value='bian_hua_qian',xoffset=440,yoffset=40)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=65,uname='1_txt')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=64,uname='1_open')
  ;输入框2
  labelin=widget_label(tlb,value='bian_hua_hou',xoffset=440,yoffset=120)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=145,uname='2_txt')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=144,uname='2_open')
  ;输出变化量路径框
  labelin=widget_label(tlb,value='out_bian_hua_liang',xoffset=440,yoffset=200)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=225,uname='3_txt')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=224,uname='3_open')
  ;输出变化强度路径框
  labelin=widget_label(tlb,value='out_bian_hua_qiang_du',xoffset=440,yoffset=280)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=305,uname='4_txt',/editable)
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=304,uname='4_open')
  ;运行按钮
  btnran=widget_button(tlb,value='RUN',xsize=100,ysize=30,xoffset=580,yoffset=380,uname='5_run')
  ;定义图像显示窗口ID
  widget_control,tlb,/realize
  widget_control,draw,get_value=win
  widget_control,tlb,set_uvalue=win
  xmanager,'bian_hua_jian_ce',tlb,/no_block
end

pro bian_hua_jian_ce_event,ev
  compile_opt idl2  ;优化调用方式
  envi,/restore_base_save_file
  envi_batch_init,log_file='batch.tix'
  ;获取文本狂变量
  bian_hua_qian=widget_info(ev.top,find_by_uname='1_txt')
  bian_hua_hou=widget_info(ev.top,find_by_uname='2_txt')
  out_liang=widget_info(ev.top,find_by_uname='3_txt')
  out_power=widget_info(ev.top,find_by_uname='4_txt')
  uname=widget_info(ev.id,/uname);获取事件uname
  
  case uname of
    '1_open':begin;获取分类前的路径并显示
      envi_open_file,a,r_fid=fid_1
      widget_control,bian_hua_qian,set_value=a
      ;显示图像
      envi_file_query,fid_1,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=fltarr(ns,nl,nb)
      for i=0,nb-1 do begin
      data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor
      ;处理但波段和多波段的显示问题
      if nb ge 3 then begin
      view=fltarr(550,400,3)
      view=congrid(data,400,400,3)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view,true=3
      endif else begin
      view=fltarr(550,400)
      view=congrid(data,400,400)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view
      endelse
      end
    '2_open':begin;获取分类后的路径并显示
      envi_open_file,a,r_fid=fid_1
      widget_control,bian_hua_hou,set_value=a
      envi_file_query,fid_1,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      ;显示
      data=fltarr(ns,nl,nb)
      for i=0,nb-1 do begin
      data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor
      view=fltarr(550,400,3)
      view=congrid(data,400,400,3)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view,true=3
      end
    '3_open':begin;获取输出变化量的路径
      envi_open_file,a,r_fid=fid_1
      widget_control,out_liang,set_value=a
      end
    '4_open':begin;获取输出变化强度的路径
      envi_open_file,a,r_fid=fid_1
      widget_control,out_power,set_value=a
      end
      
;分割线----------------------------------------------------------------------
    '5_run':begin
      widget_control,bian_hua_qian,get_value=L1         ;\变化前
      widget_control,bian_hua_hou,get_value=L2         ;\变化后
      widget_control,out_liang,get_value=L3           ;变换量
      widget_control,out_power,get_value=L4         ;变化强度
      ;打开变化前图像    
      envi_open_file,L1,r_fid=fid_1
      envi_file_query,fid_1,ns=ns_1,nl=nl_1,nb=nb_1,dims=dims_1,wl=wl_1
      bian_qian=fltarr(ns_1,nl_1,nb_1)  ;创建容器
      for i=0,nb_1-1 do begin    ;写入图像
        bian_qian[*,*,i]=envi_get_data(fid=fid_1,dims=dims_1,pos=i)
      endfor
      ;打开变化后图像
      envi_open_file,L2,r_fid=fid_1
      envi_file_query,fid_1,ns=ns_1,nl=nl_1,nb=nb_1,dims=dims_1,wl=wl_1
      bian_hou=fltarr(ns_1,nl_1,nb_1)  ;创建容器
      for i=0,nb_1-1 do begin    ;写入图像
        bian_hou[*,*,i]=envi_get_data(fid=fid_1,dims=dims_1,pos=i)
      endfor
      ;计算变化量
      liang=bian_hou-bian_qian
      ;计算变化强度
      power=fltarr(ns_1,nl_1)
      for i=0,nb_1-1 do begin
      power=power+liang[*,*,i]^2
      endfor
      power=sqrt(power)
      otsu=image_threshold(power,THRESHOLD=o,/otsu)
      ;变化强度阈值处理
      for i=0,ns_1-1 do begin
        for j=0,nl_1-1 do begin
          if power[i,j] lt o then begin
            power[i,j]=power[i,j]*0
          endif
        endfor
      endfor
      ;保存下二值图像和变化区域
      envi_write_envi_file,power,dime=dims_1,out_name=L4
      envi_write_envi_file,liang,dime=dims_1,out_name=L3
      tmp=dialog_message('successful',/info)  ;弹窗
      end
;分割线----------------------------------------------------------------------- 
  endcase

end