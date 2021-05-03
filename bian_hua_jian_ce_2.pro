; ------------------------------------------------------------------
;  本程序用于对特征点进行分类
;  通过前一个程序确定的变化强度，变化量和ROI确定
;  变化强度用于掩模作用 ，roi用于确定类别的均值方差等特征值
;  输出结果为分类后的影像
;  其分类的像元值赋值规则为：属于第1类的赋值为0，第二类赋值为1.以此类推
;  其为变化部分赋值为-1
;-----------------------------------------------------------------
pro bian_hua_jian_ce_2
  tlb=widget_base(xsize=840,ysize=450,tlb_frame_attr=1,title='bian_hua_jian_ce_2')
  ;显示框口定义
  draw=widget_draw(tlb,xsize=400,ysize=400,xoffset=25,yoffset=25)
  ;变化量输入路径
  labelin=widget_label(tlb,value='input_bian_hua_liang',xoffset=440,yoffset=60)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=85,uname='1_txt')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=84,uname='1_open')
  ;ROI输入路径口
  labelin=widget_label(tlb,value='input_ROI',xoffset=440,yoffset=140)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=165,uname='2_txt')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=164,uname='2_open')
  ;分类结果输出路径
  labelin=widget_label(tlb,value='fen_lei_jie_guo',xoffset=440,yoffset=220)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=245,uname='3_txt')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=244,uname='3_open')
  ;掩模（变化强度）
  labelin=widget_label(tlb,value='MASK',xoffset=440,yoffset=300)
  textin=widget_text(tlb,xsize=30,ysize=1,xoffset=440,yoffset=325,uname='4_txt')
  btnran=widget_button(tlb,value='open',xsize=100,ysize=28,xoffset=700,yoffset=324,uname='4_open')
  ;按钮
  btnran=widget_button(tlb,value='RUN',xsize=100,ysize=30,xoffset=580,yoffset=400,uname='5_run')
 
  widget_control,tlb,/realize
  widget_control,draw,get_value=win
  widget_control,tlb,set_uvalue=win
  xmanager,'bian_hua_jian_ce_2',tlb,/no_block
end

pro bian_hua_jian_ce_2_event,ev
  compile_opt idl2  ;优化调用方式
  envi,/restore_base_save_file
  envi_batch_init,log_file='batch.tix'
  ;获取文本控件
  liang=widget_info(ev.top,find_by_uname='1_txt')
  ROI=widget_info(ev.top,find_by_uname='2_txt')
  out_lu_jing=widget_info(ev.top,find_by_uname='3_txt')
  mask_tu=widget_info(ev.top,find_by_uname='4_txt')
  uname=widget_info(ev.id,/uname);获取事件uname
  
  case uname of 
    '1_open':begin
      envi_open_file,a,r_fid=fid_1
      widget_control,liang,set_value=a
      ;显示图像
      envi_file_query,fid_1,ns=ns,nl=nl,nb=nb,dims=dims,wl=wl
      data=fltarr(ns,nl,nb)
      for i=0,nb-1 do begin
        data[*,*,i]=envi_get_data(fid=fid_1,dims=dims,pos=i)
      endfor

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
      
    '2_open':begin
      a=dialog_pickfile(/read,filter='*.txt')
      widget_control,roi,set_value=a
      end
      
    '3_open':begin
      envi_open_file,a,r_fid=fid_1
      widget_control,out_lu_jing,set_value=a
      end
      
    '4_open':begin
       envi_open_file,a,r_fid=fid_1
       widget_control,mask_tu,set_value=a
     end
      
    '5_run':begin
      widget_control,liang,get_value=L1         ;\变量
      widget_control,ROI,get_value=L2         ;\roi
      widget_control,out_lu_jing,get_value=L3           ;保存路径
      widget_control,mask_tu,get_value=L4
      ;打开变化量图
      envi_open_file,L1,r_fid=fid_1
      envi_file_query,fid_1,ns=ns_1,nl=nl_1,nb=nb_1,dims=dims_1,wl=wl_1
      bian_liang=fltarr(ns_1,nl_1,nb_1)  ;创建容器
      for i=0,nb_1-1 do begin    ;写入图像
        bian_liang[*,*,i]=envi_get_data(fid=fid_1,dims=dims_1,pos=i)
      endfor
      ;打开掩模
      envi_open_file,L4,r_fid=fid_1
      envi_file_query,fid_1,ns=ns_1,nl=nl_1,nb=nb_1,dims=dims_1,wl=wl_1
      mask=fltarr(ns_1,nl_1,nb_1)  ;创建容器
      for i=0,nb_1-1 do begin    ;写入图像
        mask[*,*,i]=envi_get_data(fid=fid_1,dims=dims_1,pos=i)
      endfor
      ;标准化
      mask=~(~mask)
      ;打开ROI图=====================================================
      openr,lun,L2,/get_lun
      ;获取类别,最大支持99类
      void=''
      readf,lun,void
      ;a是类别数
      a=fix(strmid(void,18,2))
      classname=strarr(a)
      ;获取每类的像元个数,存在类别减1的位置
      lei_bie_ge_shu=intarr(a)
      skip_lun,lun,1,/line
      for i=0,a-1 do begin
        skip_lun,lun,1,/line
        readf,lun,void
        classname[i]=void
        skip_lun,lun,1,/line
        readf,lun,void
        lei_bie_ge_shu[i]=fix(strmid(void,12,5))
      endfor
      skip_lun,lun,3,/line
      rong_qi=fltarr(total(lei_bie_ge_shu),6)  ;总体数字容器
      str=ascii_template(L2)
      data=read_ascii(L2,template=str)
      free_lun,lun
    if str.fieldcount ge 7 then begin
      rong_qi=fltarr(total(lei_bie_ge_shu),6)
      rong_qi[*,5]=(data.(7))
      rong_qi[*,4]=(data.(6))
      rong_qi[*,3]=(data.(5))
      rong_qi[*,2]=(data.(4))
      rong_qi[*,1]=data.(3)
      rong_qi[*,0]=(data.(2)) 
      endif else begin
        rong_qi=fltarr(total(lei_bie_ge_shu),2)
        rong_qi[*,1]=data.(3)
        rong_qi[*,0]=(data.(2))
      endelse
      ;分割线=============================================================================================
 ;      ,a                          共有a类
 ;      ,lei_bie_ge_shu             每类的个数
 ;      ,rong_qi                    存放各属的像元值   
      ;算出各类；类心
      lei_ji=[0,lei_bie_ge_shu]
      for i=1,a do begin 
        lei_ji[i]=lei_ji[i-1]+lei_ji[i];计算类别累计分布
      endfor
      print,lei_ji
 
      ;把四类的像元弄出来，提取其类心
      if str.fieldcount ge 10 then begin
      lei=fltarr(6,a)
      for m=0,a-1 do begin
       for i=lei_ji[m],lei_ji[m+1]-1 do begin
        lei[0,m]=rong_qi[i,0]+lei[0,m]
        lei[1,m]=rong_qi[i,1]+lei[1,m]
        lei[2,m]=rong_qi[i,2]+lei[2,m]                
        lei[3,m]=rong_qi[i,3]+lei[3,m]
        lei[4,m]=rong_qi[i,4]+lei[4,m]
        lei[5,m]=rong_qi[i,5]+lei[5,m]
       endfor
      endfor
      endif else begin
        lei=fltarr(2,a)
        for m=0,a-1 do begin
          for i=lei_ji[m],lei_ji[m+1]-1 do begin
          lei[0,m]=rong_qi[i,0]+lei[0,m]
          lei[1,m]=rong_qi[i,1]+lei[1,m]
          endfor
        endfor
     endelse
     
     
      for m=0,a-1 do begin     
        lei[*,m]=lei[*,m]/lei_bie_ge_shu[m]  ;得出均值
      endfor
      
    ;数组lei是各类类心  ,共有a类
    ;分割线--------------------------------------------------------
    result=intarr(ns_1,nl_1)
    
    
    if str.fieldcount ge 10 then begin
     for i=0,ns_1-1 do begin
      for j=0,nl_1-1 do begin
       ;这里是遍历像元 
        distence=fltarr(a);距离容器，每次循环置零
        ;计算距离
        for m=0,a-1 do begin
        sum=0.0
        sum=(bian_liang[i,j,0]-lei[0,m])^2
        sum=(bian_liang[i,j,1]-lei[1,m])^2+sum
        sum=(bian_liang[i,j,2]-lei[2,m])^2+sum
        sum=(bian_liang[i,j,3]-lei[3,m])^2+sum
        sum=(bian_liang[i,j,4]-lei[4,m])^2+sum
        sum=(bian_liang[i,j,5]-lei[5,m])^2+sum
        distence[m]=sqrt(sum)
        endfor
        ;寻找distence距离最小的值的下标
        bb=0;下标
        v=distence[0]
        for m=0,a-1 do begin
          if v gt distence[m] then begin
            v=distence[m]
            bb=m
          endif
        endfor
        result[i,j]=bb
      ;遍历像元到此为至   
      endfor
     endfor
     
     endif else begin
      
       for i=0,ns_1-1 do begin
         for j=0,nl_1-1 do begin
           ;这里是遍历像元
           distence=fltarr(a);距离容器，每次循环置零
           ;计算距离
           for m=0,a-1 do begin
             sum=0.0
             sum=(bian_liang[i,j,0]-lei[0,m])^2+(bian_liang[i,j,1]-lei[1,m])^2
             distence[m]=sqrt(sum)
           endfor
           ;寻找distence距离最小的值的下标
           bb=0;下标
           v=distence[0]
           for m=0,a-1 do begin
             if v gt distence[m] then begin
               v=distence[m]
               bb=m
             endif
           endfor
           result[i,j]=bb
           ;遍历像元到此为至
         endfor
       endfor
      
     endelse
     
     
     ;遍历mask，把阈值为零的地方赋-1，（NaN）
     for i=0,ns_1-1 do begin
      for j=0,nl_1-1 do begin
        if mask[i,j] eq 0 then begin
          result[i,j]=-1
        endif
      endfor
    endfor
    
    result=result+1
    for i=0,a-1 do begin
      classname[i]=strmid(classname[i],11,strlen(classname[i])-10)
    endfor
         print,classname
     ;显示分类结果
     view=fltarr(550,400)
     view=congrid(result,400,400)
     widget_control,ev.top,get_uvalue=win
     wset,win
     tvscl,view
     
     
     ys=dblarr(3,a+1)
     for i=0,a do begin
       ys[0,i]=255/a*i
       ys[1,i]=255/a*(i+2)
       ys[2,i]=255/a*(i+1)
     endfor

    classname=['Unclassified',classname]
     
     ;保存
     envi_write_envi_file,result,dime=dims_1,out_name=L3, CLASS_NAMES=classname,FILE_TYPE= 3l,num_classes=a+1,lookup=ys
      end 
  endcase
  
  
    
end