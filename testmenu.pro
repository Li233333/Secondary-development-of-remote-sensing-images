pro testMenu
 base = widget_base( xsize = 1000,ysize =5,tlb_frame_attr =0, title = 'Secondary development of remote sensing images', mbar = bar)  ;容器中添加主菜单，命名为bar
 ;第一部分
 a = WIDGET_BUTTON(bar,VALUE='Preprocessing',/MENU)
 a1 = WIDGET_BUTTON(a,VALUE='Strip Noise Removal-on/off',uname='1')  ;创建下拉菜单中的按钮;声明按钮所属的菜单 ;菜单按钮中的文字
 a2 = WIDGET_BUTTON(a,VALUE='Strip Noise Removal-off/off',uname='2')  ;创建下拉菜单中的按钮;声明按钮所属的菜单 ;菜单按钮中的文字
 a3= WIDGET_BUTTON(a,VALUE='Radiation Calibration',uname='3');创建下拉菜单;声明下拉菜单所属的主菜单;菜单项中的文字
 a4 = WIDGET_BUTTON(a,VALUE='QUAC',uname='4')   ;创建下拉菜单中的按钮;声明按钮所属的菜单;菜单按钮中的文字 
 ;第二部分
 b= WIDGET_BUTTON( bar,VALUE='City Retrival',/MENU);创建下拉菜单;声明下拉菜单所属的主菜单;菜单项中的文字
 b1= WIDGET_BUTTON( b,VALUE='Temperature Retrival',uname='5');创建下拉菜单;声明下拉菜单所属的主菜单;菜单项中的文字
 b2 = WIDGET_BUTTON( b,VALUE='Vegetation Coverage',uname='6');创建下拉菜单;声明下拉菜单所属的主菜单;菜单项中的文字
 b3 = WIDGET_BUTTON( b,VALUE='City Impermeable Laye',uname='7');创建下拉菜单;声明下拉菜单所属的主菜单;菜单项中的文字
;第三部分
 c = WIDGET_BUTTON( bar,VALUE='Change Detection',/MENU);创建下拉菜单;声明下拉菜单所属的主菜单;菜单项中的文字
 c1 = WIDGET_BUTTON(c,VALUE='Change Vctor and Intensity',uname='8')   ;创建下拉菜单中的按钮;声明按钮所属的菜单;菜单按钮中的文字
 c2=WIDGET_BUTTON(c,VALUE='Feature Point Classification',uname='9')
 WIDGET_CONTROL, base, /REALIZE
 xmanager, 'testmenu', base, /no_block
 end
 
 
pro testMenu_event,ev
  ;获取textIn控件的id
  uname = widget_info(ev.id, /uname)  ;获取触发事件的控件的uname
  
  case uname of
    '1':begin;on/off去条带
      qu_tiao_dai
    end
    '2':begin;off/off去条带
      qu_tiao_dai_2
    end
    '3':begin;辐射定标
      fu_she_ding_biao1
      end
    '4':begin;大气校正
      da_qi_jiao_zheng
      end
    '5':begin;温度反演
      test_temperature
      end
    '6':begin;植被覆盖度
      Fv
      end
    '7':begin;城市不透水层指数
      water
      end
    '8':begin;变化向量
      bian_hua_jian_ce
      end
    '9':begin;分类
      bian_hua_jian_ce_2
      end
    endcase
 end