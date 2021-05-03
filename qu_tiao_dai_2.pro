;;本程序用于landsat7的去条带。off/off方法
;输入为一幅待修复条带影像，和两幅用于修复的Landsat7影像，以及他们的掩模文件。输出为去完条带后的影像
;本程序支持到单波段去条带和多波段去条带，
;多波段去条带即多光谱去条带（由于各波段的掩模文件不一致，所要需要使用ENVI工具将个波段的掩模合在一起）
pro qu_tiao_dai_2
 tlb=widget_base(xsize=1200,ysize=670,tlb_frame_attr=1,title='SLC_off-SLC_off')
 labelin=widget_label(tlb,value='qu_tiao_dai_qian_tu',xoffset=25,yoffset=5)
 labelin=widget_label(tlb,value='qu_tiao_dai_hou_tu',xoffset=625,yoffset=5)
 draw1=widget_draw(tlb,xsize=550,ysize=400,xoffset=25,yoffset=30)
 draw2=widget_draw(tlb,xsize=550,ysize=400,xoffset=625,yoffset=30)
 
 labelin=widget_label(tlb,value='dai_xiu_fu_tu',xoffset=25,yoffset=440)
 textin=widget_text(tlb,xsize=30,ysize=1,xoffset=25,yoffset=460,uname='1_txt_dai_xiu_fu')
 btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=345,yoffset=458,uname='1_open_dai_xiu_fu')
 
 labelin=widget_label(tlb,value='input_mask_0',xoffset=25,yoffset=490)
 textin=widget_text(tlb,xsize=30,ysize=1,xoffset=25,yoffset=510,uname='2_txt_mask_0')
 btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=345,yoffset=508,uname='2_open_mask_0')
 
 labelin=widget_label(tlb,value='input_biao_zhun_1',xoffset=25,yoffset=540)
 textin=widget_text(tlb,xsize=30,ysize=1,xoffset=25,yoffset=560,uname='3_txt_biao_zhun_1')
 btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=345,yoffset=558,uname='3_open_biao_zhun_1')
 
 labelin=widget_label(tlb,value='input_mask_1',xoffset=25,yoffset=590)
 textin=widget_text(tlb,xsize=30,ysize=1,xoffset=25,yoffset=610,uname='4_txt_mask_1')
 btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=345,yoffset=608,uname='4_open_mask_1')
 
 labelin=widget_label(tlb,value='input_biao_zhun_2',xoffset=625,yoffset=440)
 textin=widget_text(tlb,xsize=30,ysize=1,xoffset=625,yoffset=460,uname='5_txt_biao_zhun_2')
 btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=945,yoffset=458,uname='5_open_biao_zhun_2')
 
 labelin=widget_label(tlb,value='input_mask_2',xoffset=625,yoffset=490)
 textin=widget_text(tlb,xsize=30,ysize=1,xoffset=625,yoffset=510,uname='6_txt_mask_2')
 btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=945,yoffset=508,uname='6_open_mask_2')
 
 labelin=widget_label(tlb,value='shu_chu_lu_jing',xoffset=625,yoffset=540)
 textin=widget_text(tlb,xsize=30,ysize=1,xoffset=625,yoffset=560,uname='7_txt_save')
 btnran=widget_button(tlb,value='choose',xsize=100,ysize=30,xoffset=945,yoffset=558,uname='7_save')
 
 btnran=widget_button(tlb,value='run-SLC_off/off',xsize=150,ysize=30,xoffset=800,yoffset=610,uname='8_run')
 
 widget_control,tlb,/realize
 widget_control,draw1,get_value=win
 widget_control,draw2,get_value=win2
 widget_control,tlb,set_uvalue=[win,win2]
 xmanager,'qu_tiao_dai_2',tlb,/no_block
end


;tmp=dialog_message('succsses',/info)


pro qu_tiao_dai_2_event,ev
  compile_opt idl2  ;优化调用方式
  envi,/restore_base_save_file
  envi_batch_init,log_file='batch.tix'
  
  dai_xiu_fu=widget_info(ev.top,find_by_uname='1_txt_dai_xiu_fu')
  mask_0=widget_info(ev.top,find_by_uname='2_txt_mask_0')
  biao_zhun_tu_1=widget_info(ev.top,find_by_uname='3_txt_biao_zhun_1')
  mask_1=widget_info(ev.top,find_by_uname='4_txt_mask_1')
  biao_zhun_tu_2=widget_info(ev.top,find_by_uname='5_txt_biao_zhun_2')
  mask_2=widget_info(ev.top,find_by_uname='6_txt_mask_2')
  out_save=widget_info(ev.top,find_by_uname='7_txt_save')
  uname=widget_info(ev.id,/uname);获取事件uname
  
  case uname of
    '1_open_dai_xiu_fu':begin ;打开待修复图并且显示
      envi_open_file,a,r_fid=fid_1
      widget_control,dai_xiu_fu,set_value=a
      envi_file_query,fid_1,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=intarr(ns,nl,nb)
      for i=0,nb-1 do begin
        data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor
      view=intarr(550,400)
      view=congrid(data[*,*,[2,1,0]],550,400,3)
      widget_control,ev.top,get_uvalue=win
      wset,win[0]
      tvscl,view,true=3
      end
    '2_open_mask_0':begin;获取待修复图掩模的路径
      envi_open_file,a,r_fid=fid_1
      widget_control,mask_0,set_value=a
      end
    '3_open_biao_zhun_1':begin ;获取标准图1的路径
      envi_open_file,a,r_fid=fid_1
      widget_control,biao_zhun_tu_1,set_value=a    
      end
    '4_open_mask_1':begin  ;获取标准图1的掩模路径
      envi_open_file,a,r_fid=fid_1
      widget_control,mask_1,set_value=a
      end
    '5_open_biao_zhun_2':begin;标准图2的路径
      envi_open_file,a,r_fid=fid_1
      widget_control,biao_zhun_tu_2,set_value=a
      end
    '6_open_mask_2':begin;获取标准图2的掩模路径
      envi_open_file,a,r_fid=fid_1
      widget_control,mask_2,set_value=a
      end
    '7_save':begin;获取输出路径
      envi_open_file,a,r_fid=fid_1
      widget_control,out_save,set_value=a
      end
      
      
;分界线---------------------------------------------------------------      
    '8_run':begin
      widget_control,dai_xiu_fu,get_value=L0
      widget_control,mask_0,get_value=L1
      widget_control,biao_zhun_tu_1,get_value=L2
      widget_control,mask_1,get_value=L3
      widget_control,biao_zhun_tu_2,get_value=L4
      widget_control,mask_2,get_value=L5
      widget_control,out_save,get_value=L6
      
      ;打开待修复图像
      envi_open_file,L0,r_fid=fid_1
      envi_file_query,fid_1,ns=ns_1,nl=nl_1,nb=nb_1,dims=dims_1,wl=wl_1
      xiu_fu=intarr(ns_1,nl_1,nb_1)  ;创建容器
      for i=0,nb_1-1 do begin    ;写入图像
        xiu_fu[*,*,i]=envi_get_data(fid=fid_1,dims=dims_1,pos=i)
      endfor
      
      ;打开基准图1
      envi_open_file,L2,r_fid=fid_2
      envi_file_query,fid_2,ns=ns_2,nl=nl_2,nb=nb_2,dims=dims_2,wl=wl_2
      biao_zhun_1=intarr(ns_2,nl_2,nb_2)   ;创建容器
      for i=0,nb_2-1 do begin     ;写入图像
        biao_zhun_1[*,*,i]=envi_get_data(fid=fid_2,dims=dims_2,pos=i)
      endfor
      
      ;打开基准图2
      envi_open_file,L4,r_fid=fid_3
      envi_file_query,fid_3,ns=ns_2,nl=nl_2,nb=nb_2,dims=dims_2,wl=wl_2
      biao_zhun_2=intarr(ns_2,nl_2,nb_2)   ;创建容器
      for i=0,nb_2-1 do begin     ;写入图像
        biao_zhun_2[*,*,i]=envi_get_data(fid=fid_3,dims=dims_2,pos=i)
      endfor
      
      ;打开掩模图像0
      envi_open_file,L1,r_fid=fid_4
      envi_file_query,fid_4,ns=ns_3,nl=nl_3,nb=nb_3,dims=dims_3,wl=wl_3
      mask_0=intarr(ns_3,nl_3,nb_3)   ;创建容器
      for i=0,nb_3-1 do begin     ;写入图像
        mask_0[*,*,i]=envi_get_data(fid=fid_4,dims=dims_3,pos=i)
      endfor
      
      
      ;打开掩模图像1
      envi_open_file,L3,r_fid=fid_5
      envi_file_query,fid_5,ns=ns_3,nl=nl_3,nb=nb_3,dims=dims_3,wl=wl_3
      mask_1=intarr(ns_3,nl_3,nb_3)   ;创建容器
      for i=0,nb_3-1 do begin     ;写入图像
        mask_1[*,*,i]=envi_get_data(fid=fid_5,dims=dims_3,pos=i)
      endfor
      
      
      ;打开掩模图像2
      envi_open_file,L5,r_fid=fid_6
      envi_file_query,fid_6,ns=ns_3,nl=nl_3,nb=nb_3,dims=dims_3,wl=wl_3
      mask_2=intarr(ns_3,nl_3,nb_3)   ;创建容器
      for i=0,nb_3-1 do begin     ;写入图像
        mask_2[*,*,i]=envi_get_data(fid=fid_6,dims=dims_3,pos=i)
      endfor
      
      result=intarr(ns_1,nl_1,nb_1)
      ;开始遍历    窗口设置为31
      for d=0, nb_1-1 do begin                      
      for i=15,ns_1-16 do begin
        for j=15,nl_1-16 do begin
          ;判断好坏像元
          if mask_0[i,j,d] then begin
            result[i,j,d]=xiu_fu[i,j,d] ;好像元情况
          endif else begin
            ;以下是坏像元情况-----------------------------------------------------
            if mask_1[i,j,d] then begin;如果第一个图是好像元
               str1=xiu_fu[i-15:i+15,j-15:j+15,d]
               str2=biao_zhun_1[i-15:i+15,j-15:j+15,d]
               mask1=mask_0[i-15:i+15,j-15:j+15,d]
               mask2=mask_1[i-15:i+15,j-15:j+15,d]
               result[i,j,d]=fun(str1,str2,mask1,mask2)           
            endif else if mask_2[i,j,d] then begin;第一个base是坏的，第二个是好的
               str1=xiu_fu[i-15:i+15,j-15:j+15,d]
               str2=biao_zhun_2[i-15:i+15,j-15:j+15,d]
               mask1=mask_0[i-15:i+15,j-15:j+15,d]
               mask2=mask_2[i-15:i+15,j-15:j+15,d]
               result[i,j,d]=fun(str1,str2,mask1,mask2)       
            endif else begin;如果三个全是坏像元,随便取个均值
               str1=xiu_fu[i-15:i+15,j-15:j+15,d]
               mask1=mask_0[i-15:i+15,j-15:j+15,d]
               result[i,j,d]=fun1(str1,mask1)  
            endelse
            ;分割线--------------------------------------------------------------
          endelse
        endfor
      endfor
      endfor
      
      a=result[15:ns_1-16,15:nl_1-16,*]
      view=intarr(550,400)
      view=congrid(a[*,*,[2,1,0]],550,400,3)
      widget_control,ev.top,get_uvalue=win
      wset,win[1]
      tvscl,view,true=3
      envi_write_envi_file,a,dime=dims_1,wl=wl_1,out_name=L6    
      end;8_run的结束end符号
;分界线---------------------------------------------------------------
  endcase
end


function fun,str1,str2,mask1,mask2
;统计计算都是好像元的个数，以及计算矩阵的元素值
m=0 & a12=0 & a22=0
b1=0  &  b2=0
for i=0,30 do begin
  for j=0,30 do begin
    if mask1[i,j] && mask2[i,j] then begin
      m=m+1 
    endif
  endfor
endfor
arr1=intarr(m)
arr2=intarr(m)
p=0
for i=0,30 do begin
  for j=0,30 do begin
    if mask1[i,j] && mask2[i,j] then begin
      arr1[p]=str1[i,j] ;pri待修复
      arr2[p]=str2[i,j]  ;fill修复
      p++
    endif
  endfor
endfor
k=stddev(arr1)/stddev(arr2)
b=mean(arr1)-mean(arr2)*k
  if k le 1.0/3.0|| k gt 3 then begin
    k=1
    b=mean(arr1)-mean(arr2)*k
  endif
return, str2[15,15]*k+b
end



function fun1,str1,mask1
;统计计算都是好像元的个数，
m=0 & b=0LL
for i=0,30 do begin
  for j=0,30 do begin
    if  mask1[i,j] then begin
      m++
      b=b+str1[i,j]
    endif
  endfor
endfor
return,b/m
end