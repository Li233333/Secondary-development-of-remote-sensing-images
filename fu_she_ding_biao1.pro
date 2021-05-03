;本程序用于遥感图像辐射定标，支持landsat5和landsat7的多光谱以及热红外校正
;多光谱定标输入为遥感图像，输出为辐亮度
;热红外定标输入为热红红外图像，输出为亮温值，用于之后的温度反演

pro fu_she_ding_biao1
   tlb=widget_base(xsize=800,ysize=400,tlb_frame_attr=1,title='fu_she_ding_biao')
  base1=widget_base(tlb,xsize=310,ysize=350,xoffset=25,yoffset=25,frame=1)
  base2=widget_base(tlb,xsize=425,ysize=250,xoffset=350,yoffset=25,frame=1)
  ;功能介绍
  labelin=widget_label(base1, value='If you put image from TM,Please click', xoffset=10,yoffset=20)
  labelin=widget_label(base1, value='the button "run-L5",or if you put the', xoffset=10,yoffset=45)
  labelin=widget_label(base1, value='image of ETM+,Please click the ', xoffset=10,yoffset=70)
  labelin=widget_label(base1, value= '"run-L7"', xoffset=10,yoffset=95)
  ;创建文件输入控件
  labelin=widget_label(base2,value='open input file',xoffset=10,yoffset=20)
  textin=widget_text(base2,xsize=40,ysize=1,xoffset=10,yoffset=35,uname='1_txt')
  outfile=widget_text(base2,xsize=40,ysize=1,xoffset=10,yoffset=185,uname='2_txt')
  ;创建文件保存控件
  lab=widget_label(base2,value='save path',xoffset=10,yoffset=165)
  btnopen=widget_button(base2,value='open',xsize=70,ysize=25,xoffset=350,yoffset=35,uname='3_open')
  openoutputfile=widget_button(base2,value='save',xsize=70,ysize=25,xoffset=350,yoffset=185,uname='4_save')
  ;创建命令执行控件
  btnran_L7=widget_button(tlb,value='L5-Thermal',xsize=135,ysize=30,xoffset=380,yoffset=350,uname='5_L5-Thermal')
  btnran_L7=widget_button(tlb,value='L5-Multispectral',xsize=135,ysize=30,xoffset=380,yoffset=300,uname='5_L5-Multispectral')
  btnran_L5=widget_button(tlb,value='L7-Thermal',xsize=135,ysize=30,xoffset=600,yoffset=350,uname='6_L7-Thermal')
  btnran_L5=widget_button(tlb,value='L7-Multispectral',xsize=135,ysize=30,xoffset=600,yoffset=300,uname='6_L7-Multispectral')
  widget_control,tlb,/realize
  xmanager,'fu_she_ding_biao1',tlb,/no_block
end
pro fu_she_ding_biao1_event,ev
  compile_opt idl2  ;优化调用方式
  envi,/restore_base_save_file
  envi_batch_init,log_file='batch.tix'
 ;获取信息
  textin1=widget_info(ev.top,find_by_uname='1_txt')
  textin2=widget_info(ev.top,find_by_uname='2_txt')
  uname=widget_info(ev.id,/uname)
 ;定标系数设置
  gain_5=[0.765827,1.448189,1.043976,0.876024,0.120354,0.055376,0.065551]
  gain_7=[0.778740,0.798819,0.621654,0.969291,0.126220,0.043898]
  bias_5=[-2.29,-4.29,-2.21,-2.39,-0.49,1.18,-0.22]
  bias_7=[-6.98,-7.20,-5.62,-6.07,-1.13,-0.39]
  gain7=[0.067087,0.037205]
  bias7=[-0.07,3.16]

  case uname of
    '3_open':begin ;单击打开按钮
      envi_open_file,fname,r_fid=fid
      widget_control,textin1,set_value=fname
      print,fname
    end
    '4_save':begin  ;保存按钮
      choose=dialog_pickfile(/write)
      widget_control,textin2,set_value=choose
    end
  ;L5定标
    '5_L5-Multispectral':begin
      widget_control,textin1,get_value=fname
      widget_control,textin2,get_value=choose
      envi_open_file,fname,r_fid=fid
      envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=intarr(ns,nl,nb)  ;创建容器
      for i=0,nb-1 do begin    ;写入图像
        data[*,*,i]=envi_get_data(fid=fid,dims=dims,pos=i)
      endfor
      for i=0,nb-1 do begin ;利用定标参数进行辐射定标
        data[*,*,i]=data[*,*,i]*gain_5[i]+bias_5[i];辐射定标公式。L=k*DN+b
      endfor
      data=data>1
      envi_write_envi_file,data,out_name=choose,wl=wl  ;保存图像
      tmp=dialog_message('successful,Please find the file in the definition of the output path ',/info)  ;弹窗
    end
    '5_L5-Thermal':begin
      widget_control,textin1,get_value=fname
      widget_control,textin2,get_value=choose
      envi_open_file,fname,r_fid=fid
      envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=dblArr(ns,nl,nb)  ;创建容器 ;写入图像
      data=dblArr(ns,nl,nb)  ;创建容器 ;写入图像
      for i=0,nb-1 do begin    ;写入图像
        data[*,*,i]=envi_get_data(fid=fid,dims=dims,pos=i)
      endfor
      data=0.055376*(data)+1.18
      data1=1260.56/alog((607.76/data)+1)
      data1=data1>1
      envi_write_envi_file,data1,out_name=choose,wl=wl  ;保存图像
      tmp=dialog_message('successful,Please find the file in the definition of the output path ',/info)  ;弹窗
    end
    ;L7定标
    '6_L7-Multispectral':begin
      
      widget_control,textin1,get_value=fname
      widget_control,textin2,get_value=choose
      envi_open_file,fname,r_fid=fid
      envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=intarr(ns,nl,nb)
      for i=0,nb-1 do begin    ;写入图像
        data[*,*,i]=envi_get_data(fid=fid,dims=dims,pos=i)
      endfor
      for i=0,nb-1 do begin ;利用定标参数进行辐射定标
        data[*,*,i]=data[*,*,i]*gain_7[i]+bias_7[i];辐射定标公式。L=k*DN+b
      endfor
   
      envi_write_envi_file,data,out_name=choose,wl=wl;保存图像
      tmp=dialog_message('successful,Please find the file in the definition of the output path ',/info) ;弹窗
    end
    '6_L7-Thermal':begin
      widget_control,textin1,get_value=fname
      widget_control,textin2,get_value=choose
      envi_open_file,fname,r_fid=fid
      envi_file_query,fid,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=dblArr(ns,nl,nb)
      for i=0,nb-1 do begin    ;写入图像
        data[*,*,i]=envi_get_data(fid=fid,dims=dims,pos=i)
      endfor
      data2=dblArr(ns,nl,nb)
      for i=0,nb-1 do begin ;利用定标参数进行辐射定标
        data[*,*,i]= gain7[i]*(data[*,*,i])+bias7[i]
        data2[*,*,i]=1260.56/alog((607.76/data[*,*,i])+1)
      endfor
   
      envi_write_envi_file,data2,out_name=choose,wl=wl;保存图像
      tmp=dialog_message('successful,Please find the file in the definition of the output path ',/info) ;弹窗
    end
  endcase
end