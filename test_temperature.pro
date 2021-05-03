;本程序用于反演研究区地表温度，使用单窗算法
;输入亮度温度，多光谱图像。以及地表大气温度和相对湿度。
;输出为地表温度
pro test_temperature
  tlb=widget_base(xsize=800,ysize=400,tlb_frame_attr=0,title='temperature')
 btnRun = widget_button(tlb,value = 'Run',xsize = 100, ysize =30, xoffset = 600, yoffset = 350 , uname= 'Run' )
 base1 = widget_base( tlb,xsize = 300, ysize = 350,xoffset = 25,yoffset = 25,frame = 1)
 base2 = widget_base(tlb, xsize = 425,ysize = 300,xoffset = 350,yoffset = 25,frame = 1 )
 draw = widget_draw( base1, xsize = 280,ysize = 340,xoffset = 10,yoffset = 5 )
;输入文件控件
  labelin=widget_label(base2,value='open QUAC_result file',xoffset = 10,yoffset = 10 )
  textIn1 = widget_text(base2,xsize = 40, ysize = 1,xoffset = 10,yoffset = 25,uname = 'textIn1' )
  btnOpen1 = widget_button(base2, value = 'Open',xsize = 70,ysize = 25, xoffset = 350,yoffset = 25, uname = 'buttonIn1' )
  ;输入参数T
  labelin=widget_label(base2,value='T',xoffset = 20,yoffset = 185 )
  textInT = widget_text(base2,xsize = 10, ysize = 1,xoffset = 40,yoffset = 180,uname = 'textInT',/editable)
 ;输入参数RH
  labelin=widget_label(base2,value='RH',xoffset = 220,yoffset = 185 )
  textRH = widget_text(base2,xsize = 10, ysize = 1,xoffset = 250,yoffset = 180,uname = 'textRH',/editable)
;输入文件控件
  labelin=widget_label(base2,value='open liang_wen file',xoffset = 10,yoffset = 70 )
  textIn2 = widget_text(base2, xsize = 40, ysize = 1,xoffset = 10,yoffset = 90,uname = 'textIn2' )
  btnOpen2 = widget_button(base2,value = 'Open',xsize = 70,ysize = 25,xoffset = 350, yoffset = 90,uname = 'buttonIn2')
;输出文件控件
  labelin=widget_label(base2,value='open export file',xoffset = 10,yoffset = 230 )
  textsave = widget_text(base2, xsize = 40, ysize = 1,xoffset = 10, yoffset = 250,uname = 'textsave' )
  btnesave = widget_button( base2,value = 'export', xsize = 70,ysize = 25,xoffset = 350, yoffset = 250,uname = 'buttonsave' )
 widget_control, tlb, /realize  ;保存图像控件的窗口ID
  widget_control, draw, get_value = win;获取图像控件的窗口ID
  widget_control,tlb,set_uvalue=win
  xmanager,'test_temperature',tlb,/no_block
end

pro test_temperature_event, ev
  ;获取控件的id
  COMPILE_OPT IDL2
  ENVI,/restore_base_save_file
  ENVI_batch_INIT
  textIn1 = widget_info(ev.top, find_by_uname = 'textIn1')
  textIn2 = widget_info(ev.top, find_by_uname = 'textIn2')
  textsave = widget_info(ev.top, find_by_uname = 'textsave')
  textInT = widget_info(ev.top, find_by_uname = 'textInT')
  textRH = widget_info(ev.top, find_by_uname = 'textRH')
  uname = widget_info(ev.id, /uname)  ;获取触发事件的控件的uname
  case uname of
    ;读取大气校正数据
    'buttonIn1' :begin 
      fileIn1=dialog_pickfile()
      widget_control,textIn1,set_value=fileIn1 
      ENVI_OPEN_FILE,fileIn1,R_FID=fid
      if(fid eq -1) then return
      ENVI_FILE_QUERY,fid, dims=dims, nb=nb,ns=ns,nl=nl,w1=wl
      arr1=dblarr(ns,nl,nb)
     for i=0,nb-1 do begin
        arr1[*, *, i]=ENVI_GET_DATA(FID=fid,dims=dims,pos=i)
    endfor
    data1=dblarr(350,340,3)
     data1[*,*,0]=congrid(reform(arr1[*,*,4]),350,340)
     data1[*,*,1]=congrid(reform(arr1[*,*,3]),350,340)
     data1[*,*,2]=congrid(reform(arr1[*,*,2]),350,340)
     widget_control, ev.top, get_uvalue = win
     wset, win
    tvscl,data1,true=3,/order
   end
   ;读取thermal数据
 'buttonIn2' : begin  ;如果点击Open按钮，则执行以下操作
     fileIn2=dialog_pickfile()
      widget_control,textIn2,set_value=fileIn2
      ENVI_OPEN_FILE,fileIn2,R_FID=fid
      if(fid eq -1) then return
      ENVI_FILE_QUERY,fid, dims=dims, nb=nb,ns=ns,nl=nl,w1=w1
      arr2=dblArr(ns,nl,nb)
     for i=0,nb-1 do begin
        arr2[*,*,i]=ENVI_GET_DATA(FID=fid,dims=dims,pos=i)
    endfor
    data2=dblarr(350,340,1)
       data2=congrid(reform(arr2),350,340)
      widget_control, ev.top, get_uvalue = win
       wset, win
      tvscl,data2,/order
 end
 ;数据保存路径
   'buttonsave' : begin  ;如果点击export按钮，则执行以下操作
      fileOut = dialog_pickfile(/write)  ;保存文件对话框
      widget_control, textSave, set_value = fileOut  ;修改文本框内容
    end
  ;数据处理 
  'Run' : begin  ;如果点击Run按钮，则执行以下操作
      widget_control, textIn1, get_value = fileIn1;
      widget_control, textIn2, get_value = fileIn2;
      widget_control, textsave, get_value =fileOut;
      widget_control, textInT, get_value =T;
      widget_control, textRH, get_value =RH;
     COMPILE_OPT IDL2
      ENVI,/restore_base_save_file
      ENVI_batch_INIT
     ENVI_OPEN_FILE,fileIn1,R_FID=fid
     ENVI_FILE_QUERY,fid, dims=dims, nb=nb,ns=ns,nl=nl,w1=w1
      arr1=dblArr(ns,nl,nb)
     for i=0,nb-1 do begin
        arr1[*,*,i]=ENVI_GET_DATA(FID=fid,dims=dims,pos=i)
     endfor
  q=float((arr1[*,*,3]-arr1[*,*,2])/float(arr1[*,*,3]+arr1[*,*,2]))     ;计算ndvi值
  ;ndvi归一化
  ndvi=dblarr(ns,nl)
   for n=0,ns-1 do begin
    for m=0,nl-1 do begin
      if q[n,m] lt -1 then begin
        q[n,m]=-1
      endif else if q[n,m] ge -1 and q[n,m] lt 1 then begin
        q[n,m]=q[n,m]
      endif else if q[n,m] gt 1 then begin
        q[n,m]=1
     endif 
     endfor
     endfor
        g=finite(q,/nan)*(0.995)or(~finite(q,/nan))*q     ;ndvi结果去nan值
    ndvi=g
ENVI_OPEN_FILE,fileIn2,R_FID=fid
    ENVI_FILE_QUERY,fid, dims=dims, nb=nb,ns=ns,nl=nl,w1=w1
      arr2=dblArr(ns,nl,nb)
      for i=0,nb-1 do begin
        arr2[*,*,i]=ENVI_GET_DATA(FID=fid,dims=dims,pos=i)
      endfor
    RH=RH[0]
    T=T[0]
      w=0.0981*(6.1078*10^((7.5*T)/(T+273.3)))*RH+0.1697    ;计算大气水分含量
      tao=0.974290-0.08007*w                                 ;大气透过率
      Ta=16.0110+0.92621*(T+273.3)                           ;大气平均气温
;计算植被覆盖度
      ndvisort=ndvi[sort(ndvi)] ;排序
      num=n_elements(ndvi)  ;像元总数
      num5=long(num*0.05)  ;累计像元个数为5%所对应的下标
      num95=long(num*0.95) ;累计像元个数为95%所对应的下标
      ndvis=ndvisort[num5] ;累积频率为5%所对应的NDVI值
      ndviv=ndvisort[num95] ;累积平率为95%所对应的NDVI值
      pv=(ndvi-ndvis)/(ndviv-ndvis)
      sigmal=0.004*pv+0.986   ;计算地表比辐射率
      D=float(1-tao)*float((1+(1-sigmal)*tao))
      C=float(sigmal*tao) 
  ;计算地表温度                   
    k=1-C-D
    r1=float((-67.355351)*k)     
    r2=float(0.458606*k)            
      y=r2+C+D               
    u=float(y*(arr2))               
    o=float(D*Ta)                  
    p=r1+u-o                 
    Ts=float(p/C)
    Ts=Ts-273.3  ;温度单位换算为摄氏度
  envi_write_envi_file,Ts,out_name=fileOut,wl=wl
     tmp = dialog_message('successful!', /info) ;显示提示框
    end
  endcase
   ENVI_batch_EXIT
end



