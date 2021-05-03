;本程序用于landsat5和landsat7的大气校正，输入可以为多光谱或热红外图像
;输出为为辐射亮度
pro da_qi_jiao_zheng
  tlb=widget_base(xsize=800,ysize=400,tlb_frame_attr=1,title='da_qi_jiao_zheng')
  base1=widget_base(tlb,xsize=300,ysize=350,xoffset=20,yoffset=25,frame=1)
  base2=widget_base(tlb,xsize=425,ysize=300,xoffset=350,yoffset=25,frame=1)
  draw=widget_draw(base1,xsize=300,ysize=350,xoffset=0,yoffset=0)

  labelin=widget_label(tlb, value='result preview', xoffset=25,yoffset=4)
  labelin=widget_label(base2,value='open input file',xoffset=10,yoffset=20)
  lab=widget_label(base2,value='save path',xoffset=10,yoffset=165)
  textin=widget_text(base2,xsize=40,ysize=1,xoffset=10,yoffset=35,uname='1_txt')
  outfile=widget_text(base2,xsize=40,ysize=1,xoffset=10,yoffset=185,uname='2_txt')
  btnopen=widget_button(base2,value='open',xsize=70,ysize=25,xoffset=350,yoffset=35,uname='3_open')
  openoutputfile=widget_button(base2,value='save',xsize=70,ysize=25,xoffset=350,yoffset=185,uname='4_save')
  btnran=widget_button(tlb,value='run',xsize=100,ysize=30,xoffset=650,yoffset=350,uname='5_run')
  widget_control,tlb,/realize
  widget_control,draw,get_value=win
  widget_control,tlb,set_uvalue=win
  xmanager,'da_qi_jiao_zheng',tlb,/no_block
end




;
pro da_qi_jiao_zheng_event,ev
  compile_opt idl2  ;优化调用方式
  envi,/restore_base_save_file
  envi_batch_init,log_file='batch.tix'
  
  
  textin1=widget_info(ev.top,find_by_uname='1_txt')
  textin2=widget_info(ev.top,find_by_uname='2_txt')
  uname=widget_info(ev.id,/uname);获取事件uname
  
  
  case uname of
    '3_open':begin
      envi_open_file,fname,r_fid=fid_1
      widget_control,textin1,set_value=fname
      
      envi_open_file,fname ,r_fid=fid_1
      envi_file_query,fid_1,ns=ns_1,nl=nl_1,nb=nb_1,dims=dims_1,wl=wl_1
      b=intarr(ns_1,nl_1,nb_1)  ;创建容器
      for i=0,nb_1-1 do begin    ;写入图像
        b[*,*,i]=envi_get_data(fid=fid_1,dims=dims_1,pos=i)
      endfor
      a=b[*,*,[4,3,2]]
      view=intarr(300,350)
      view=congrid(a,300,350,3)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view,true=3
      end
    '4_save':begin
      choose=dialog_pickfile(/write)
      widget_control,textin2,set_value=choose
      end 
    '5_run':begin
      widget_control,textin1,get_value=fname    ;获取路径
      widget_control,textin2,get_value=choose
      
      envi_open_file,fname,r_fid=fid
      envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      pos=indgen(nb)
      envi_doit,'envi_quac_doit',fid=fid,pos=pos,dims=dims,out_name=choose,r_fid=r_fid  ;校正
      
      envi_open_file,choose,r_fid=fid_1
      data=intarr(ns,nl,nb)
      for i=0,nb-1 do begin    ;写入图像
        data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor
      view=intarr(300,350,3)
      view=congrid(data[*,*,[2,1,0]],550,400,3)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view,true=3

      tmp=dialog_message('successful',/info)  ;弹窗
      end  
  endcase

end
