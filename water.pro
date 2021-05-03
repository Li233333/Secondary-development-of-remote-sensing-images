pro water
  tlb=widget_base(xsize=900,ysize=400,tlb_frame_attr=1,title='water')
  base1=widget_base(tlb,xsize=400,ysize=350,xoffset=25,yoffset=25,frame=1)
  draw=widget_draw(base1,xsize=400,ysize=350,xoffset=0,yoffset=0)
  labelin=widget_label(tlb, value='preview', xoffset=25,yoffset=4)

  labelin=widget_label(tlb, value='open input file', xoffset=500,yoffset=25)
  textin=widget_text(tlb, xsize=20,ysize=1,xoffset=500,yoffset=50,uname='1_text_lnput')
  btnopen=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=700,yoffset=50,uname='2_open_lnput')

  labelin=widget_label(tlb, value='output file', xoffset=500,yoffset=125)
  textin=widget_text(tlb, xsize=20,ysize=1,xoffset=500,yoffset=150,uname='3_text_save')
  btnopen=widget_button(tlb,value='save',xsize=100,ysize=30,xoffset=700,yoffset=150,uname='4_open_out')

  btnran_L5_BCI=widget_button(tlb,value='run-L5-BCI',xsize=150,ysize=30,xoffset=500,yoffset=225,uname='5_run-L5-BCI')
  btnran_L7_BCI=widget_button(tlb,value='run-L7-BCI',xsize=150,ysize=30,xoffset=500,yoffset=325,uname='6_run-L7-BCI')

  widget_control,tlb,/realize
  widget_control,draw,get_value=win;
  widget_control,tlb,set_uvalue=win;
  xmanager,'water',tlb,/no_block
end

pro water_event,ev
  compile_opt idl2
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
      data=fltarr(ns,nl,nb)
      for i=0,nb-1 do begin
        data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor
      a=data[*,*,[2,1,0]]
      view=fltarr(400,350)
      view=congrid(a,400,350,3)
      widget_control,ev.top,get_uvalue=win
      wset,win
      tvscl,view,true=3
    end
    '4_open_out':begin
      a=dialog_pickfile(/write)
      widget_control,text_2,set_value=a
    end
  
  '5_run-L5-BCI':begin
  widget_control,text_1,get_value=input
  widget_control,text_2,get_value=out
  envi_open_file,input,r_fid=fid
  envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
  data=fltarr(ns,nl,nb)
  for  i=0,nb-1 do begin
    data[*,*,i]=envi_get_data(fid=fid,dims=dims,pos=i)   
  endfor
  TC1_5=data[*,*,0]*0.3037+data[*,*,1]*0.2793+data[*,*,2]*0.4343+data[*,*,3]*0.5585+data[*,*,4]*0.5082+data[*,*,5]*0.1863
  TC2_5=data[*,*,0]*(-0.2848)+data[*,*,1]*(-0.2435)+data[*,*,2]*(-0.5436)+data[*,*,3]*0.7243+data[*,*,4]*0.0840+data[*,*,5]*(-0.1800)
  TC3_5=data[*,*,0]*0.1509+data[*,*,1]*0.1793+data[*,*,2]*0.3299+data[*,*,3]*0.3406+data[*,*,4]*(-0.7112)+data[*,*,5]*(-0.4572)
  BCI=float([(TC1_5+TC3_5)/2-TC2_5])/float([(TC1_5+TC3_5)/2+TC2_5])
  MBSI=float((data[*,*,2]-data[*,*,1])*2)/float((data[*,*,2]+data[*,*,1]-2))
  MNDWI=float((data[*,* ,1]-data[*,*,4]))/float((data[*,*,1]+data[*,*,4]))
  a=where(MNDWI gt 1,complement=b)
  MNDWI[a]=0
  MNDWI[b]=1
  T_5=MNDWI*BCI-MBSI*0.5
  T_5=-2>T_5<3
  view=fltarr(400,350)
  view=congrid(T_5,400,350) 
  widget_control,ev.top,get_uvalue=win
  wset,win
  tvscl,view
  envi_write_envi_file,T_5,dime=dims,wl=wl,out_name=out
end
    
'6_run-L7-BCI':begin
  widget_control,text_1,get_value=input
  widget_control,text_2,get_value=out
  envi_open_file,input,r_fid=fid
  envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
  data=fltarr(ns,nl,nb)
  for  i=0,nb-1 do begin
    data[*,*,i]=envi_get_data(fid=fid,dims=dims,pos=i)
  endfor
  TC1_7=data[*,*,0]*0.3561+data[*,*,1]*0.3972+data[*,*,2]*0.3904+data[*,*,3]*0.6966+data[*,*,4]*0.2286+data[*,*,5]*0.1596
  TC2_7=data[*,*,0]*(-0.3344)+data[*,*,1]*(-0.3544)+data[*,*,2]*(-0.4556)+data[*,*,3]*0.6966+data[*,*,4]*(-0.0242)+data[*,*,5]*(-0.2630)
  TC3_7=data[*,*,0]*0.2626+data[*,*,1]*0.2141+data[*,*,2]*0.0926+data[*,*,3]*0.0656+data[*,*,4]*(-0.7629)+data[*,*,5]*(-0.5388)
  BCI=float([(TC1_7+TC3_7)/2-TC2_7])/float([(TC1_7+TC3_7)/2+TC2_7])
  MBSI=float((data[*,*,2]-data[*,*,1])*2)/float((data[*,*,2]+data[*,*,1]-2))
  MNDWI=float((data[*,* ,1]-data[*,*,4]))/float((data[*,*,1]+data[*,*,4]))
  a=where(MNDWI gt 1,complement=b)
  MNDWI[a]=0
  MNDWI[b]=1
  T_7=MNDWI*BCI-MBSI*0.5
  T_7=(T_7 le 0.2 and b1 gt 0)*0.2+(b1 le 0.4 and b1 ge 0.2)*0.4
  view=fltarr(400,350)
  view=congrid(T_7,400,350)
  widget_control,ev.top,get_uvalue=win
  wset,win
  tvscl,view
  envi_write_envi_file,view,dime=dims,wl=wl,out_name=out
end   
endcase
end