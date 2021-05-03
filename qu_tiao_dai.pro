;本程序用于landsat7的去条带。on/off方法
;输入为一幅条带影像及其掩模文件，和一幅标准影像，输出为去完条带后的影像
;本程序支持到单波段去条带和多波段去条带，
;多波段去条带即多光谱去条带（由于各波段的掩模文件不一致，所要需要使用ENVI工具将个波段的掩模合在一起）
pro qu_tiao_dai
  tlb=widget_base(xsize=1200,ysize=620,tlb_frame_attr=1,title='SLC_on-SLC_off')
  ;静态文本
  labelin=widget_label(tlb,value='qu_tiao_dai_qian_tu',xoffset=25,yoffset=5)
  labelin=widget_label(tlb,value='qu_tiao_dai_hou_tu',xoffset=625,yoffset=5)
  
  base1=widget_base(tlb,xsize=550,ysize=400,xoffset=25,yoffset=30,frame=1)
  draw1=widget_draw(base1,xsize=550,ysize=400,xoffset=0,yoffset=0)
  draw2=widget_draw(tlb,xsize=550,ysize=400,xoffset=625,yoffset=30)

  labelin=widget_label(tlb,value='dai_xiu_fu_tu',xoffset=25,yoffset=440)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=25,yoffset=460,uname='1_txt_dai_xiu_fu')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=325,yoffset=458,uname='2_open_dai_xiu_fu')

  labelin=widget_label(tlb,value='biao_zhun_tu',xoffset=25,yoffset=490)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=25,yoffset=510,uname='3_txt_biao_zhun')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=325,yoffset=508,uname='4_open_biao_zhun')


  labelin=widget_label(tlb,value='input_mask',xoffset=25,yoffset=540)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=25,yoffset=560,uname='5_txt_mask')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=30,xoffset=325,yoffset=558,uname='6_open_mask')

  labelin=widget_label(tlb,value='shu_chu_lu_jing',xoffset=625,yoffset=460)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=625,yoffset=480,uname='7_txt_out')
  btnran=widget_button(tlb,value='choose',xsize=100,ysize=30,xoffset=925,yoffset=478,uname='8_save')


  btnran=widget_button(tlb,value='run-SLC_on/off',xsize=150,ysize=30,xoffset=800,yoffset=550,uname='9_run')


  widget_control,tlb,/realize
  widget_control,draw1,get_value=win
  widget_control,draw2,get_value=win2
  widget_control,tlb,set_uvalue=[win,win2]
  xmanager,'qu_tiao_dai',tlb,/no_block
end


pro qu_tiao_dai_event,ev
  compile_opt idl2  ;优化调用方式
  envi,/restore_base_save_file
  envi_batch_init,log_file='batch.tix'

  dai_xiu_fu=widget_info(ev.top,find_by_uname='1_txt_dai_xiu_fu')
  biao_zhun_tu=widget_info(ev.top,find_by_uname='3_txt_biao_zhun')
  mask=widget_info(ev.top,find_by_uname='5_txt_mask')
  out_save=widget_info(ev.top,find_by_uname='7_txt_out')
  uname=widget_info(ev.id,/uname);获取事件uname
  case uname of
    '2_open_dai_xiu_fu':begin
      envi_open_file,a,r_fid=fid_1
      widget_control,dai_xiu_fu,set_value=a
      ;显示图像
      envi_file_query,fid_1,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=intarr(ns,nl,nb)
      for i=0,nb-1 do begin
        data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor
      a=data[*,*,[2,1,0]]
      view=intarr(550,400)
      view=congrid(a,550,400,3)
      widget_control,ev.top,get_uvalue=win
      wset,win[0]
      tvscl,view,true=3
    end
    '4_open_biao_zhun':begin
      envi_open_file,a,r_fid=fid_1
      widget_control,biao_zhun_tu,set_value=a
    end
    '6_open_mask':begin
      envi_open_file,a,r_fid=fid_1
      widget_control,mask,set_value=a
    end
    '8_save':begin
      envi_open_file,a,r_fid=fid_1
      widget_control,out_save,set_value=a
    end
    '9_run':begin
      widget_control,dai_xiu_fu,get_value=lu_jin_1           ;待修复
      widget_control,biao_zhun_tu,get_value=lu_jin_2           ;标准图
      widget_control,mask,get_value=lu_jin_3                ;掩模
      widget_control,out_save,get_value=lu_jin_4            ;输出路径
      ;打开待修复图像
      envi_open_file,lu_jin_1 ,r_fid=fid_1
      envi_file_query,fid_1,ns=ns_1,nl=nl_1,nb=nb_1,dims=dims_1,wl=wl_1
      xiu_fu=intarr(ns_1,nl_1,nb_1)  ;创建容器
      for i=0,nb_1-1 do begin    ;写入图像
        xiu_fu[*,*,i]=envi_get_data(fid=fid_1,dims=dims_1,pos=i)
      endfor
      ;打开基准图
      envi_open_file,lu_jin_2 ,r_fid=fid_2
      envi_file_query,fid_2,ns=ns_2,nl=nl_2,nb=nb_2,dims=dims_2,wl=wl_2
      biao_zhun=intarr(ns_2,nl_2,nb_2)   ;创建容器
      for i=0,nb_2-1 do begin     ;写入图像
        biao_zhun[*,*,i]=envi_get_data(fid=fid_2,dims=dims_2,pos=i)
      endfor
      ;打开掩模图像
      envi_open_file,lu_jin_3 ,r_fid=fid_3
      envi_file_query,fid_3,ns=ns_3,nl=nl_3,nb=nb_3,dims=dims_3,wl=wl_3
      mask=intarr(ns_3,nl_3,nb_3)   ;创建容器
      for i=0,nb_3-1 do begin     ;写入图像
        mask[*,*,i]=envi_get_data(fid=fid_3,dims=dims_3,pos=i)
      endfor
      mask=~(~mask)
      ;将基准图biao_zhun设置成与待修复xiufu图像一致,以防万一
      if nb_2 le 2 then begin
      var=size(xiu_fu,/Dimensions)
      if size(var,/n_Dimensions) le 2 then begin
        var1=make_array(3,value=1) & var1[0:1]=var & var=var1
      endif
      biao_zhun=congrid(biao_zhun,var[0],var[1],var[2])
      endif else begin
        var=size(xiu_fu,/Dimensions)
        biao_zhun=congrid(biao_zhun,ns_1,nl_1,nb_1)
        endelse
      ;经过考虑，认为窗口大小设置为25较为合适,此时，xiu_fu的大小为ns_1*nl_1*nb_1，列行维
      result=intarr(ns_1,nl_1,nb_1) ;用于存放新数组
      ;开始无脑遍历
      for i=0,nb_1-1 do begin    ;维数
        for j=12,ns_1-13 do begin    
          for k=12,nl_1-13 do begin
           if mask[j,k,i] eq 1 then begin
            result[j,k,i]=xiu_fu[j,k,i]
           endif else begin
            ;先计算出窗口内有多少个好像元--------------------------
            index=0
            for m=j-12,j+12 do begin
              for n=k-12,k+12 do begin
                if mask[m,n,i] then index=index+1
              endfor
            endfor
            ;再将好像元的值载入新数组并计算均值，方差之类的杂七杂八的东西----------------
            var_xf=intarr(index)
            var_bz=intarr(index)
            index2=0
            for m=j-12,j+12 do begin
              for n=k-12,k+12 do begin
                if mask[m,n,i] eq 1 then begin
                  var_xf[index2]=xiu_fu[m,n,i]
                  var_bz[index2]=biao_zhun[m,n,i]
                  index2=index2+1
                endif
              endfor
            endfor
            mean_xf=mean(var_xf)
            fc_xf=stddev(var_xf)
            mean_bz=mean(var_bz)
            fc_bz=stddev(var_bz)
            ;计算新像元值分界线------------------
            result[j,k,i]=(fc_xf/fc_bz)*(biao_zhun[j,k,i]-mean_bz)+mean_xf
            ;功成分界线-------------------
            endelse
          endfor
        endfor
      endfor
     ;----------以上循环得出新图像，在此保存，分割线-----------------------------
     
   if nb_1 le 2 then begin
     a=result[12:ns_1-13,12:nl_1-13,0]
     view=intarr(550,400)
     view=congrid(a,550,400,1)
     widget_control,ev.top,get_uvalue=win
     wset,win[1]
     tvscl,view
     end else begin
       a=result[12:ns_1-13,12:nl_1-13,[2,1,0]]
       view=intarr(550,400,3)
       view=congrid(a,550,400,3)
       widget_control,ev.top,get_uvalue=win
       wset,win[1]
       tvscl,view,true=3
      endelse
         envi_write_envi_file,result[12:ns_1-13,12:nl_1-13,*],dime=dims_1,wl=wl_1,out_name=lu_jin_4 
     end
   
   endcase
   ENVI_batch_EXIT
end