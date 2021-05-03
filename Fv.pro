;本程序用于计算植被覆盖度
;使用像元二分模型计算得到
;输入为多光谱影像
;输出为植被覆盖度影像

pro Fv
  tlb=widget_base(xsize=800,ysize=400,tlb_frame_attr=1,title='fvc')
  base1=widget_base(tlb,xsize=300,ysize=350,xoffset=25,yoffset=25,frame=1)
  base2=widget_base(tlb,xsize=425,ysize=300,xoffset=350,yoffset=25,frame=1)
  draw=widget_draw(base1,xsize=300,ysize=350,xoffset=0,yoffset=0)


  labelin=widget_label(base2,value='open input file',xoffset=10,yoffset=10)
  textin=widget_text(base2,xsize=35,ysize=1,xoffset=10,yoffset=35,uname='1_text_lnput')
  btnopen=widget_button(base2,value='open',xsize=70,ysize=25,xoffset=350,yoffset=35,uname='2_open_lnput')

  labelin=widget_label(base2,value='output file',xoffset=10,yoffset=100)
  textin=widget_text(base2,xsize=35,ysize=1,xoffset=10,yoffset=125,uname='3_text_save')
  btnopen=widget_button(base2,value='save',xsize=70,ysize=25,xoffset=350,yoffset=125,uname='4_open_out')

  button=widget_button(tlb,value='run',xsize=100,ysize=30,xoffset=600,yoffset=350,uname='5_run')

  widget_control,tlb,/realize
  widget_control,draw,get_value=win;
  widget_control,tlb,set_uvalue=win;
  xmanager,'Fv',tlb,/no_block
end

pro Fv_event,ev
  compile_opt idl2  ;优化调用方式
  envi,/restore_base_save_file
  envi_batch_init,log_file='batch.tix'
  
  text_1=widget_info(ev.top,find_by_uname='1_text_lnput')
  text_2=widget_info(ev.top,find_by_uname='3_text_save')
  uname=widget_info(ev.id,/uname)
  
  case uname of
    '2_open_lnput':begin
      envi_open_file,a,r_fid=fid_1
      widget_control,text_1,set_value=a                    
      envi_file_query,fid_1,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=intarr(ns,nl,nb)
      for i=0,nb-1 do begin
        data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor
      a=data[*,*,[2,1,0]]
      view=intarr(300,350)
      view=congrid(a,300,350,3)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view,true=3
    end
    '4_open_out':begin
      a=dialog_pickfile(/write)
      widget_control,text_2,set_value=a
    end
    '5_run':begin
      widget_control,text_1,get_value=input
      widget_control,text_2,get_value=out
      envi_open_file,input,r_fid=fid
      envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      yuan_tu=intarr(ns,nl,nb)   ;创建容器
      for i=0,nb-1 do begin     ;写入图像
        yuan_tu[*,*,i]=envi_get_data(fid=fid,dims=dims,pos=i)
      endfor
      ndvi_nir=yuan_tu[*,*,3]
      ndvi_red=yuan_tu[*,*,2]
      ndvi=float((ndvi_nir-ndvi_red))/float((ndvi_nir+ndvi_red))
      
      ndvisort=ndvi[sort(ndvi)]
      n=size(ndvi,/n_element)
      n5=long(n*0.05)  & n95=long(n*0.95)
      ndvi_s=ndvisort[n5] & ndvi_v=ndvisort[n95]
      fvc=(ndvi-ndvi_s)/(ndvi_v-ndvi_s)
      
      view=intarr(300,350)
      view=congrid(fvc,300,350)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view
      
      envi_write_envi_file,fvc,dime=dims,wl=wl,out_name=out
    end
  endcase
end
