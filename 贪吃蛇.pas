PROGRAM Snake_____by_Fallen_breath;       //gotoxy(x*2+1,y+1);

{$M 10000000,0,maxlongint}

USES crt,dos,sysutils;

CONST maxx=38;
      maxy=21;
      version='1.0.1';
      filename='snake_save';
      savesfoldername='saves';
      date='  2014.03.09'; //len=12

      maxmoney=100000000;
      maxlengthofpassword=70;
      maxlengthofusername=20;

      maxtipwaiting=10000;
      bfmt=400;
      bigfoodappearnumber=12;
      multiplenumber=20;

      maxprop=10;
      propappearnum:array[1..maxprop] of longint=(1,0,0,0,0,0,0,0,0,0);
      propchar:array[1..maxprop] of string=('☆','¤','－','','','','','','','');
      propname:array[1..maxprop] of string=('集束食物弹','','','','','','','','','');

      maxdaoju=4;
      dj1min{lian chi}=2;
      dj1jl{ji lv}=2;
      dj2lf{last for}=500;
      dj2fw{fan wei}=4;
      dj2c{char}=11;
      djname:array[1..maxdaoju] of string=('焚化','磁性','','');
      djprice:array[1..maxdaoju] of longint=(100,70,0,0);

      ln=chr(13)+chr(10);
      snakechar:array[1..6] of string=('┌','└','┘','┐','─','│');
      headchar='⊙';
      bigfoodchar='★';
      foodchar='☆';
      obstaclechar='▓';
      moneychar='◎';

TYPE map_type=record
                x,y:longint;
              end;
     time_type=record
                 h,m,s,s100,oy:word;
                 x:longint;
               end;
     prop_type=record
                 zb:array[1..1000] of map_type;
                 time:time_type;
                 appear:boolean;
                 num:longint;
               end;
     tip_type=record
                colour,lastfor:longint;
                s:ansistring;
                time:time_type;
                appear:boolean;
              end;
     data_type=record
                 maxfen:array[1..11] of int64;
                 money:longint;
                 maxlevel:longint;
                 nam,password:string;
                 whereisme:ansistring;
                 pressbreak,diis{double input improve speed}:boolean;
               end;


VAR i,j,t,tt,t1,t2,t3:longint;
    len,de,dela,bu,wf,level,max,bfbt,gamemode:longint;
    oldmoney:longint;
    twn{tipwaitingnumber},propnum,multiple:longint;
    fen:int64;

    snake:array[0..maxx*maxy+2] of map_type;
    food,bfood:map_type;
    prop:array[1..maxprop] of prop_type;    //1:集束食物  2:清除障碍  3:减蛇长  4:  5:  6:  7:  8:  9:  10:
    daoju:array[1..maxdaoju] of prop_type;
    tipwaiting:array[1..maxtipwaiting] of tip_type;
    map:array[0..maxy+2,0..maxx+2] of longint;//蛇身:3  蛇头:2  道具:4  食物:6  5:障碍  空地:8

    data:data_type;
    win,lose,bf,gua,god,id,saveshide:boolean;
    wjin,wjout:text;
    wj:file;


function can(x,y,m:longint):boolean;forward;
procedure new(var x,y:longint);forward;
procedure inmi(var s:string);forward;

procedure gt(var n:time_type);
begin
  with n do
  begin
    gettime(h,m,s,s100);
    x:=h*360000+m*6000+s*100+s100;
  end;
end;
procedure tc(n:longint);
begin
  textcolor(n);
end;
procedure tb(n:longint);
begin
  textbackground(n);
end;

procedure delay(n:longint);
var a,b,c,d,oldday,newday:word;
    i,t,now:longint;
begin
  n:=n div 10;
  gettime(a,b,c,d);
  t:=a*360000+b*6000+c*100+d;
  getdate(a,b,oldday,d);
  repeat
    if keypressed then readkey;
    getdate(a,b,newday,d);
    gettime(a,b,c,d);
    now:=a*360000+b*6000+c*100+d;
    if newday<>oldday then inc(now,8640000);
  until (now-t>=n);
end;
  {
function readkey():char;
begin
  exit(crt.readkey);
end;

procedure readkey;
var c:char;
begin
  while not keypressed do;
  c:=crt.readkey;
  if c=chr(0) then c:=crt.readkey;
end;
             }
function inputn(ws:ansistring):longint;
var ii,i,j,ln,n,x,ly,fy,lns,maxlen:longint;
    left,right:array[1..100] of longint;
    st:string;
    s:array[1..100] of string;
begin
  for i:=1 to 100 do
   s[i]:='';
  ii:=0;
  repeat
    tc(8);tb(0);
    inputn:=200;
    if ii<>0 then clrscr;
    ii:=1;
    gotoxy(wherex+3,wherey);
    x:=wherex;fy:=wherey;
    i:=0;j:=0;
    left[1]:=wherex;
    ws:=ws+chr(13)+chr(10);
    repeat
      inc(i);
      if ws[i] in [chr(13),chr(10)]=false then s[j+1]:=s[j+1]+ws[i]
       else begin
         gotoxy(x,wherey);write(s[j+1]);
         inc(i);inc(j);
         right[j]:=wherex;
         gotoxy(x,wherey+1);
         left[j+1]:=wherex;
       end;
    until i>=length(ws);
    ly:=wherey;
    lns:=ly-fy;
    maxlen:=-maxlongint;
    for i:=1 to lns do
     if right[i]-left[i]>maxlen then maxlen:=right[i]-left[i];
    n:=1;ln:=-1;
    repeat
      if ln<>n then
      begin
        if ln<>-1 then
        begin
          tc(8);tb(0);
          gotoxy(left[ln]-3,fy+ln-1);
          write('   ',s[ln]);
          gotoxy(left[ln]+maxlen+1,fy+ln-1);
          write('  ');
        end;
        tc(15);
        gotoxy(left[n]-3,fy+n-1);
        write('≡ ',s[n]);
        gotoxy(left[n]+maxlen+1,fy+n-1);
        write('≡');
        ln:=n;
      end;
      if keypressed then
      begin
        st:=readkey;
        if (st[1]=chr(0)) and keypressed then
        begin
          st:=upcase(readkey);
          case st[1] of
            chr(80):begin
                      if n<lns then inc(n)
                       else n:=1;
                    end;
            chr(72):begin
                      if n>1 then dec(n)
                       else n:=lns;
                    end;
          end;
        end
         else if st=chr(13) then break;
      end;//end if keypressed
    until false;
    inputn:=n;
  until true;
end;

function inputint(s:ansistring;l,r,q:longint):longint;
var i,n:longint;
    st:string;
begin
  i:=0;
  repeat
    tc(7);
    inputint:=200;
    if i<>0 then clrscr;
    i:=1;
    writeln(s);
    cursoron;
    readln(st);
    if (upcase(st)='/GAMEMODE 1') or (upcase(st)='GOD MODE OPEN') then
    begin
      god:=true;
      tc(12);
      if st[1]='/' then writeln('您的游戏模式已更新')
       else writeln('上帝模式开启！');
      delay(500);
    end;
    if (upcase(st)='/GAMEMODE 0') or (upcase(st)='GOD MODE CLOSE') then
    begin
      god:=false;
      tc(12);
      if st[1]='/' then writeln('您的游戏模式已更新')
       else writeln('上帝模式关闭！');
      delay(500);
    end;
    tc(7);
    cursoroff;
    val(st,inputint,n);
    if q=2 then
    begin
      if st='-1' then exit(-1);
      if st='-2' then exit(-2);
    end;
    if q=1 then
      if st='-1' then exit(-1);
  until (n=0) and (inputint>=l) and (inputint<=r);
end;

procedure print_max_fen;
var i:longint;
begin
  tc(13);
  writeln('最高闯关──第',data.maxlevel,'关');
  tc(8);if data.maxlevel>=7 then write('感谢你的支持，源码解压密码为：Od32OY4D36UEF_c#4ohn');writeln;
  tc(12);
  writeln('NO.1   ',data.maxfen[1]);
  tc(14);
  writeln('NO.2   ',data.maxfen[2]);
  tc(11);
  writeln('NO.3   ',data.maxfen[3]);
  tc(15);
  for i:=4 to 9 do
    writeln('NO.',i,'   ',data.maxfen[i]);
  writeln('NO.10  ',data.maxfen[10]);
  tc(7);
  readkey;
  clrscr;
end;

function can(x,y,m:longint):boolean;                 //m 1:snake
var i:longint;
begin
  can:=true;
  if ((y in [1..maxy])=false) or ((x in [1..maxx])=false) and ((m<>1) or ((m=1) and (level<>-1))) then exit(false);
  if map[y,x]<>8 then can:=false;
  if (m=1) and (map[y,x] in [2,6]) then can:=true;
end;

function isprop(x,y:longint):boolean;
var i,j:longint;
begin
  for i:=1 to maxprop do
   with prop[i] do
    for j:=1 to num do
     if (x=zb[j].x) and (y=zb[j].y) then
     begin
       propnum:=i;
       exit(true);
     end;
  exit(false);
end;

procedure new(var x,y:longint);
var i:longint;
begin
  repeat
    x:=random(maxx)+1;
    y:=random(maxy)+1;
  until can(x,y,0);
end;

procedure tip(s:ansistring;colour:longint);
var i,j,t:longint;
begin
  gotoxy((maxx div 2)*2-(length(s) div 2)+3,maxy+2);
  tc(colour);
  tb(8);
  write(s);
  tc(15);
end;

procedure inmi(var s:string);
var i,ii:longint;
    c:char;
begin
  s:='';
  cursoron;
  tc(7);
  repeat
    c:=readkey;
    if ((c<>chr(13)) and (c<>chr(8)) and (ord(c)<=31)) or (ord(c)>126) then continue;
    if (c=chr(13)) or (c=chr(0)+chr(28)) then break;
    if c=chr(8) then
    begin
      if s='' then continue;
      gotoxy(wherex-1,wherey);
      tb(8);write(' ');
      gotoxy(wherex-1,wherey);
      delete(s,length(s),1);
      continue;
    end;
    if length(s)=maxlengthofpassword then continue;
    s:=s+c;
    write('*');
  until false;
  writeln;
  cursoroff;
end;

procedure save;
var s:string;
    i,t:longint;

   function zhuan(a:longint):string;
   var c,d:longint;
       b:array[1..10000] of longint;
   begin
     d:=0;
     zhuan:='';
     repeat
       d:=d+1;
       b[d]:=a mod 16;
       a:=a div 16;
     until a=0;
     for c:=d downto 1 do
      if b[c]<10 then zhuan:=zhuan+chr(ord('0')+b[c])
       else zhuan:=zhuan+chr(ord('A')-10+b[c]);
   end;

   procedure jia(var s:string);
   var n,i:longint;//32-255
       t:string;
   begin
     n:=random(220)+1;
     t:='';
     for i:=1 to length(s) do
       t:=t+chr((ord(s[i])-32+n) mod 220+32);
     s:='';
     for i:=1 to length(t) div 2 do
       s:=s+t[i*2]+t[i*2-1];
     if odd(length(t)) then s:=s+t[length(t)];
     insert(chr(n+32),s,1);
   end;

begin
  with data do
  begin
   { money:=100000;
    maxlevel:=6;
    maxfen[1]:=3252;
    maxfen[2]:=1142;
    maxfen[3]:=954;
    maxfen[4]:=863;
    maxfen[5]:=244;
    maxfen[6]:=157;
    maxfen[7]:=10;
    daoju[1].num:=100;
    daoju[2].num:=100;
    nam:='yqx';
    password:='yangqixin'; }

    if directoryexists(savesfoldername)=false then mkdir(savesfoldername);

    assign(wj,savesfoldername+'/'+nam+'_'+filename+'.dat');
    setfattr(wj,archive);

    assign(wjout,savesfoldername+'/'+nam+'_'+filename+'.dat');
    rewrite(wjout);
    for i:=1 to 10 do
    begin
      s:=zhuan(maxfen[i]);
      jia(s);
      writeln(wjout,s);
    end;
    s:=zhuan(maxlevel);jia(s);writeln(wjout,s);
    s:=zhuan(money);jia(s);writeln(wjout,s);
    s:=password;jia(s);writeln(wjout,s);
    for i:=1 to maxdaoju do
    begin
      s:=zhuan(daoju[i].num);
      jia(s);
      writeln(wjout,s);
    end;
    writeln(wjout);
    if pressbreak then writeln(wjout,'TRUE')else writeln(wjout,'FALSE');
    if diis then writeln(wjout,'TRUE')else writeln(wjout,'FALSE');
    close(wjout);

    if saveshide then setfattr(wj,hidden);
  end;  //end with
end;

procedure load;
var i:longint;
    s:string;
    gua:boolean;

   function zhuan(s:string):longint;
   var i:longint;
       j,k,l:longint;
   begin
     j:=1;
     zhuan:=0;
     for i:=length(s) downto 1 do
     begin
       if (s[i] in ['0'..'9']) then k:=ord(s[i])-ord('0');
       if (s[i] in ['A'..'F']) then k:=ord(s[i])-ord('A')+10;
       if (s[i] in ['a'..'f']) then k:=ord(s[i])-ord('a')+10;
       zhuan:=zhuan+j*k;
       j:=j*16;
     end;
   end;

   procedure jia(var s:string);
   var n,i:longint;//32-255
       t:string;
   begin
     n:=random(220)+1;
     t:='';
     for i:=1 to length(s) do
       t:=t+chr((ord(s[i])-32+n) mod 220+32);
     s:='';
     for i:=1 to length(t) div 2 do
       s:=s+t[i*2]+t[i*2-1];
     if odd(length(t)) then s:=s+t[length(t)];
     insert(chr(n+32),s,1);
   end;

   procedure jie(var s:string);
   var t:string;
        n,i:longint;
   begin
      n:=ord(s[1])-32;
      delete(s,1,1);
      t:='';
      for i:=1 to length(s) do
        t:=t+chr((ord(s[i])-32-n+220) mod 220+32);
      s:='';
      for i:=1 to length(t) div 2 do
        s:=s+t[i*2]+t[i*2-1];
      if odd(length(t)) then s:=s+t[length(t)];
   end;

begin
  repeat
    clrscr;
    t:=inputn('载入存档'+ln+
              '新建存档'+ln+
              '  返回');
    if t=3 then begin id:=false;exit;end;
    clrscr;
    case t of
      1:begin
          i:=0;
          repeat
            tc(7);
            inc(i);
            clrscr;
            if i=5 then
            begin
              load;
              exit;
            end;
            writeln('请输入您的账号名');
            cursoron;
            readln(s);
            cursoroff;
            if fsearch(savesfoldername+'/'+s+'_'+filename+'.dat','/')='' then
            begin
              tc(15);
              writeln('此帐号不存在！');
              delay(600);
            end;
          until (length(s)<=maxlengthofusername) and (fsearch(savesfoldername+'/'+s+'_'+filename+'.dat','/')<>'');

          data.nam:=s;
          clrscr;tc(15);tb(8);writeln('Loading。。。');
          assign(wj,savesfoldername+'/'+s+'_'+filename+'.dat');
          setfattr(wj,archive);
          assign(wjin,savesfoldername+'/'+s+'_'+filename+'.dat');
          reset(wjin);
          with data do
          begin
            for i:=1 to 10 do
            begin
              readln(wjin,s);
              jie(s);
              data.maxfen[i]:=zhuan(s);
            end;
            readln(wjin,s);jie(s);data.maxlevel:=zhuan(s);
            readln(wjin,s);jie(s);data.money:=zhuan(s);
            readln(wjin,s);jie(s);data.password:=s;
            for i:=1 to maxdaoju do
            begin
              readln(wjin,s);
              jie(s);
              daoju[i].num:=zhuan(s);
            end;
            readln(wjin);
            readln(wjin,s);if s='TRUE' then pressbreak:=true else if s='FAKSE' then pressbreak:=false;
            readln(wjin,s);if s='TRUE' then diis:=true else if s='FAKSE' then diis:=false;
          end;
          close(wjin);
          if saveshide then setfattr(wj,hidden);

          clrscr;
          i:=0;
          repeat
            tc(7);
            inc(i);
            writeln('请输入密码');
          //  writeln(length(data.password));
          //  writeln(data.password);
            inmi(s);
            if data.password=s then break;
          //  break;
            tc(15);
            writeln('密码错误！');
            delay(500);
            clrscr;
            if i=5 then break;
          until false;
          if i=5 then continue;
          clrscr;
          textcolor(12);
          writeln('登录成功！');

          gua:=false;
          for i:=1 to 9 do
           if data.maxfen[i]<data.maxfen[i+1] then gua:=true;
          if gua then
           with data do
           begin
             delay(500);
             clrscr;
             textcolor(12);
             writeln('孩纸，你修改了存档。');
             delay(800);
             clrscr;
             textcolor(7);
             continue;
           end;

          delay(1000);
          textcolor(7);
          clrscr;
          exit;
        end;
      2:begin
          repeat
            if directoryexists(savesfoldername)=false then mkdir(savesfoldername);
            writeln('请输入您的帐号名（',maxlengthofusername,'个字节以内）');
            cursoron;
            readln(s);
            cursoroff;
            if (length(s) in [1..maxlengthofusername])=false then continue;
            if fsearch(savesfoldername+'/'+s+'_'+filename+'.dat','/')<>'' then
            begin
              writeln('帐号已存在！');
              delay(700);
              clrscr;
              continue;
            end;
            break;
          until false;
          data.nam:=s;
          repeat
            i:=4;
            repeat
              inc(i);
              if i>=5 then clrscr;
              if i=1000 then i:=5;
              writeln('请输入密码(至少6位）');
              inmi(data.password);
            until length(data.password) in [6..maxlengthofpassword];
            clrscr;
            writeln('请再次输入密码');
            inmi(s);
            if s=data.password then break;
            writeln('密码错误！');
            delay(500);
            clrscr;
          until false;
          save;
          writeln('创建新存档成功！');
          delay(700);
          clrscr;
          exit;
        end;
    end;
  until false;
end;

procedure init_main;
var i:longint;
    s:string;
begin
  randomize;
  cursoroff;
  with data do
  begin
    fillchar(maxfen,sizeof(maxfen),0);
    maxlevel:=0;
    pressbreak:=true;
  end;
  tc(7);
  tb(8);
  god:=false;
  saveshide:=false;
  for i:=1 to maxdaoju do
   with daoju[i] do
   begin
     for j:=1 to 1000 do
      with zb[j] do
      begin
        x:=-1;
        y:=-1;
      end;
     appear:=false;
     num:=0;
   end;
end;

procedure clean_map;
var i,j:longint;
begin
  for i:=0 to maxy+2 do
   for j:=0 to maxx+2 do
     map[i,j]:=8;
end;

procedure init_game;
var i,j,t,n:longint;
begin
  cursoroff;
  gua:=false;
  fen:=0;
  win:=false;
  lose:=false;
  clean_map;
  multiple:=-1;
  for i:=1 to maxtipwaiting do
   with tipwaiting[i] do
   begin
     colour:=0;
     lastfor:=0;
     s:='';
     appear:=false;
   end;
  twn:=0;
  for i:=1 to maxprop do
   with prop[i] do
   begin
     for j:=1 to 1000 do
      with zb[j] do
      begin
        x:=-1;
        y:=-1;
      end;
     appear:=false;
     num:=0;
   end;
  propnum:=0;
end;

procedure init_snake;
var i,j,t,n:longint;
begin
  len:=4;
  for i:=2 to len do
  begin
    snake[i].x:=5-i+1;
    snake[i].y:=5;
    map[5,5-i+1]:=3;
  end;
  snake[1].x:=5;
  snake[1].y:=5;
  map[5,5]:=4;
  de:=2;
end;

procedure init_food(m:longint);  //1 print
var i,j,n:longint;
    a:array[1..1000] of map_type;
begin
  if daoju[2].appear then
  begin
    n:=0;
    for i:=1 to maxx do
     for j:=1 to maxy do
      if (abs(snake[1].x-i)+abs(snake[1].y-j)>4) then
      begin
        inc(n);
        a[n].x:=i;
        a[n].y:=j;
      end;
    if n=0 then
    begin
      new(food.x,food.y);
    end
     else begin
       n:=random(n)+1;
       food:=a[n];
     end;
  end
   else new(food.x,food.y);
  map[food.y,food.x]:=6;
  if m=1 then
  begin
    gotoxy(food.x*2+1,food.y+1);
    tb(6);
    write(foodchar);
  end;
end;

procedure init_tip(ss:ansistring;c,l:longint);
var i,j,t:longint;
begin
  inc(twn);
  with tipwaiting[twn] do
  begin
    gt(time);
    s:=ss;
    colour:=c;
    lastfor:=l;
    if twn=1 then
     with tipwaiting[twn] do
       tip(s,colour);
  end;
end;

procedure init_prop(nn:longint);
var i,j,k,l,t,x,y,n:longint;
    b:boolean;
    a:array[1..1000] of map_type;
begin
  case nn of
    1:begin
        n:=0;
        for i:=1 to maxx-2 do
         for j:=1 to maxy-2 do
         begin
           b:=false;
           for k:=i to i+2 do
            for l:=j to j+2 do
             if map[l,k]<>8 then b:=true;
           if b=false then
           begin
             inc(n);
             a[n].x:=i;
             a[n].y:=j;
           end;
         end;
        if n=0 then
        begin
          n:=0;
          for i:=1 to maxx-2 do
           for j:=1 to maxy-2 do
           begin
             b:=false;
             for k:=i to i+2 do
              for l:=j to j+2 do
               if map[l,k] in [2,3] then b:=true;
             if b=false then
             begin
               inc(n);
               a[n].x:=i;
               a[n].y:=j;
             end;
           end;
          if n=0 then exit;
          n:=random(n)+1;
        end //end if n=0
         else n:=random(n)+1;

        for i:=a[n].x to a[n].x+2 do
         for j:=a[n].y to a[n].y+2 do
          if map[j,i]=8 then
          begin
            gotoxy(i*2+1,j+1);
            tb(2);
            write('☆');
            map[j,i]:=2;
            with prop[1] do
            begin
              inc(num);
              zb[num].x:=i;
              zb[num].y:=j;
            end;
          end;
        tb(7);
        prop[1].appear:=true;
        init_tip('集束食物弹',12,75);
      end;
    2:begin
      end;
   { 3:begin
      end;
    4:begin
      end;
    5:begin
      end;
    6:begin
      end;
    7:begin
      end;
    8:begin
      end;
    9:begin
      end;
    10:begin
      end;}
  end;
end;

procedure init_daoju(nn:longint);
var i,j,k,l,t,x,y,n:longint;
    b:boolean;
    a:array[1..1000] of map_type;
begin
  if (daoju[nn].num=0) and (god=false) then exit;
  with daoju[nn] do case nn of
    1:begin
        n:=0;
        for i:=1 to maxx do
         for j:=1 to maxy do
           if map[j,i]=5 then
           begin
             inc(n);
             a[n].x:=i;
             a[n].y:=j;
           end;
        if n=0 then exit;
        t:=random(3)+1;
        for i:=1 to t do
        begin
          if i>n then break;
          k:=random(n)+1;
          with a[k] do
          begin
            map[y,x]:=8;
            gotoxy(x*2+1,y+1);
            tb(8);
            write('  ');
          end;
        end;
        init_tip('焚化',11,75);
        dec(num);
      end;
    2:begin
        gt(time);
        init_tip('磁性',11,75);
        dec(num);
        appear:=true;

        gotoxy(28,maxy+3);
        tc(dj2c);tb(8);
        write(djname[2]);
      end;
    3:begin
        dec(num);
        appear:=true;
      end;
    4:begin
        dec(num);
        appear:=true;
      end;
    5:begin
        dec(num);
        appear:=true;
      end;
    6:begin
        dec(num);
        appear:=true;
      end;
    7:begin
        dec(num);
        appear:=true;
      end;
    8:begin
        dec(num);
        appear:=true;
      end;
    9:begin
        dec(num);
        appear:=true;
      end;
    10:begin
        dec(num);
        appear:=true;
       end;
  end;
  if god then inc(daoju[nn].num);
end;

procedure init_max;
var i,j:longint;
begin
  max:=len;
  for i:=1 to maxx do
   for j:=1 to maxy do
    if (map[j,i] in [3..5])=false then inc(max);
end;

procedure iz(lev:longint);
var i,j,k,x,y:longint;

   procedure fk(x,y,cx,cy:longint);
   var i,j:longint;
   begin
     for i:=0 to cx-1 do
      for j:=0 to cy-1 do
        map[y+j,x+i]:=5;
   end;

begin
  if lev<=0 then exit;
  for i:=4 to maxx-3 do
   if abs(i-maxx div 2)>2 then
     map[maxy div 2+1,i]:=5;
  if lev=1 then exit;
  for i:=3 to maxy-2 do
   if abs(i-maxy div 2)>2 then
     map[i,maxx div 2]:=5;
  map[maxy div 2-2,maxx div 2]:=5;
  map[maxy div 2+3,maxx div 2]:=8;
  if lev=2 then exit;
  fk(3,2,3,2);
  fk(maxx-4,2,3,2);
  fk(3,maxy-2,3,2);
  fk(maxx-4,maxy-2,3,2);
  if lev=3 then exit;
  fk(maxx div 2,maxy div 2+1,1,1);
  fk(11,5,1,6);
  fk(11,5,6,1);
  fk(8+maxx div 2,maxy div 2+1,1,7);
  fk(maxx div 2+3,maxy div 2+7,6,1);
  if lev=4 then exit;
  map[maxy div 2-2,maxx div 2-4]:=5;
  map[maxy div 2+4,maxx div 2+4]:=5;
  fk(maxx div 2+8,maxy div 2-5,1,2);
  fk(maxx div 2-8,maxy div 2+6,1,2);
  if lev=5 then exit;
  fk(4,maxy div 2-3,3,1);
  fk(4,maxy div 2-2,1,1);
  fk(4,maxy div 2+5,3,1);
  fk(4,maxy div 2+4,1,1);
  fk(maxx-5,maxy div 2-3,3,1);
  fk(maxx-3,maxy div 2-2,1,1);
  fk(maxx-5,maxy div 2+5,3,1);
  fk(maxx-3,maxy div 2+4,1,1);
  map[maxy div 2+1,10]:=8;
  map[maxy div 2+1,maxx-10]:=8;
  if lev=6 then exit;
  fk(maxx div 2+4,1,1,7);
  fk(maxx div 2-4,maxy-6,1,7);
  if lev=7 then exit;
  fk(7,maxy div 2+5,12,1);
  fk(maxx div 2,maxy div 2-3,14,1);
  if lev=8 then exit;
  for i:=1 to maxy do
   for j:=1 to maxx do
     if ((odd(i)=false) and (i<>1) and (i<>maxy)) and ((odd(j)=false) and (j<>1) and (j<>maxx)) then map[i,j]:=5
      else map[i,j]:=8;
  map[1,maxx]:=5;
  map[4,maxx]:=5;
  map[7,maxx]:=5;
  map[10,maxx]:=5;
  map[13,maxx]:=5;
  map[16,maxx]:=5;
  map[19,maxx]:=5;
  map[maxy,maxx]:=5;
  map[maxy-1,maxx]:=5;
end;

procedure pfen;
var i,add,t:longint;
begin
  add:=fen;
  t:=dela;
  if dela=-1 then dela:=0;
  inc(fen,10);
  if wf=maxlongint then
  begin
    if dela>=10 then dec(fen,dela div 10-1);
    if fen>300 then inc(fen,11-dela div 10);
    if fen>700 then inc(fen,11-dela div 10);
    if fen>1000 then inc(fen,11-dela div 10);
    if fen>1500 then inc(fen,11-dela div 10);
    if fen>2000 then inc(fen,11-dela div 10);
  end;
  if bu<multiplenumber then
  begin
    inc(fen,(multiplenumber-bu)*2);
    inc(multiple);
    if multiple>=propappearnum[1] then
    begin
      if random(dj1jl)=0 then init_prop(1);
    end;
  end else multiple:=0;
  add:=fen-add;
  dec(fen,add);
  if t=-1 then inc(add,10);
  if (wf=maxlongint) and (level>1) then add:=trunc(add*(level-1)*1.5);
  inc(fen,add);
  dela:=t;
end;

procedure init_bfood;
var i:longint;
    h,m,s,s100:word;
begin
  new(bfood.x,bfood.y);
  map[bfood.y,bfood.x]:=2;
  gotoxy(bfood.x*2+1,bfood.y+1);
  tb(2);
  write(bigfoodchar);
  bf:=true;
  gotoxy(maxx+4-25,maxy+2);
  tb(8);
  write('奖励剩余时间:4.00');
  gettime(h,m,s,s100);
  bfbt:=h*360000+m*6000+s*100+s100;
end;

procedure print_logo;
const max=17;
       s:array[1..max] of string=(
'            ☆                          ★                ⊙          ⊙        ',
'          ☆  ☆                        ★                ⊙            ⊙      ',
'        ☆      ☆        ★★★★    ★                  ⊙            ⊙      ',
'      ☆    ☆    ☆      ★    ★    ★★★★★★★★⊙⊙⊙⊙⊙  ⊙⊙⊙⊙⊙⊙⊙',
'    ☆        ☆    ☆    ★    ★  ★                ⊙  ⊙  ⊙  ⊙          ⊙',
'☆☆  ☆☆☆☆☆☆☆  ☆☆★    ★★                  ⊙  ⊙  ⊙⊙          ⊙  ',
'                ☆        ★    ★    ★★★★★★    ⊙  ⊙  ⊙    ⊙          ',
'              ☆          ★    ★              ★    ⊙  ⊙  ⊙    ⊙    ⊙    ',
'    ☆☆☆☆☆☆☆☆☆    ★    ★            ★      ⊙⊙⊙⊙⊙    ⊙  ⊙      ',
'    ☆              ☆    ★    ★        ★★        ⊙  ⊙        ⊙  ⊙      ',
'    ☆      ☆      ☆    ★★★★      ★                ⊙        ⊙⊙        ',
'    ☆      ☆      ☆    ★    ★    ★                  ⊙  ⊙    ⊙          ',
'    ☆      ☆      ☆              ★                    ⊙⊙⊙⊙  ⊙          ',
'          ☆    ☆☆                ★              ★⊙⊙      ⊙  ⊙        ⊙',
'      ☆☆          ☆☆              ★★★★★★★★⊙              ⊙⊙⊙⊙⊙',
'  ☆☆                  ☆                                                      ',
'                                                                       V'+version+' '
);
var i,j,n:longint;
begin
  for i:=1 to max do
  begin
    j:=1;
    repeat
      case j of
        1..26:tc(random(10)+1);
        27..54:tc(random(10)+5);
        55..80:repeat n:=random(10)+10;tc(n);until n mod 16<>0;
      end;
      if (i=max) and (j>20) then tc(15);
      write(s[i,j],s[i,j+1]);
      inc(j,2);
    until j>=length(s[i]);
    writeln;
  end;//end for i
end;
procedure print_info;
var i:longint;
    c:string;
begin
    gotoxy(1,maxy+2);
    tc(15);
    tb(8);
    write('分数：',fen);
    gotoxy(1,maxy+3);
    if bu<>999999 then
    begin
      write('步数：',bu);
      str(bu,c);
      for i:=1 to 7-length(c)+1 do write(' ');
    end
     else write('步数：',999999,'+');
    gotoxy(1,1);
    write('蛇长：',len,'/',max);
    if wf<>maxlongint then
    begin
      gotoxy(35,1);
      tb(8);
      if wf-fen>0 then write(' 还剩',wf-fen,'分')
       else write('关卡完成！');
    {  gotoxy(47,1);
      tb(1);
      write('══');     }
    end;
    gotoxy(maxx*2-15,1);
    tb(8);
    tc(15);
    write('连吃：');
    if (multiple<10) and (multiple>=0) then write('0');
    write(multiple);
end;

procedure print_map;
var i,j,t,n:longint;
begin
  clrscr;
  tb(1);if level=-1 then tb(0);
  tc(15);
  write('╔');
  for i:=1 to maxx do write('═');
  write('╗');
  tb(8);
    gotoxy(maxx*2-25,1);
    write('关卡：');
    if (level>0) and (level<10) then write('0');
    write(level);
    gotoxy(maxx*2-5,1);
    write('速度：');
    write(dela);
  tb(1);if level=-1 then tb(0);
  writeln;
  for i:=1 to maxy do
  begin
    tb(1);if level=-1 then tb(0);
    write('║');
    for j:=1 to maxx do
    begin
      tb(map[i,j]);
      case map[i,j] of
        0,8:{write('  ');}gotoxy(wherex+2,wherey);
        3:write(snakechar[5]);
        4:write(headchar);
        5:write(obstaclechar);
        6:write(foodchar);
      end;
    end;
    tb(1);
    writeln('║');
  end;
  write('╚');
  for i:=1 to maxx do write('═');
  write('╝');
  writeln;

  print_info;
end;

procedure play;
const gox:array[1..4] of longint=(0,1,0,-1);
      goy:array[1..4] of longint=(-1,0,1,0);
var i,t,tt,n,xx,yy,ty,tx,d,oc,nc:longint;
    h,m,s,s100:word;
    c:string;
    ss,first,longer:boolean;
    ttime:time_type;

   procedure sort;
   var i,j,k:longint;
       t:int64;
   begin
     for i:=1 to 11 do
     begin
       k:=i;
       for j:=i+1 to 11 do
        if data.maxfen[j]>data.maxfen[k] then k:=j;
       if k<>i then
       begin
         t:=data.maxfen[i];
         data.maxfen[i]:=data.maxfen[k];
         data.maxfen[k]:=t;
       end;
     end;
   end;

   procedure long(tx,ty:longint);
   var i:longint;
   begin
     inc(len);
     snake[len].x:=tx;
     snake[len].y:=ty;
     map[ty,tx]:=3;
   end;

   procedure print_daoju;
   const number:array[0..9] of string=('０','１','２','３','４','５','６','７','８','９');
   var i:longint;
   begin
     tc(15);
     tb(8);
     gotoxy(15,maxy+3);
     for i:=1 to maxdaoju do
     begin
       if djname[i]<>'' then
       begin
         gotoxy(15 + (i-1)*12,maxy+3);
         tc(15);
         //write(number[i]);
         write(i);
         tc(7);
         write(djname[i],':',daoju[i].num,' ');
       end;
     end;
     if daoju[2].appear then
     begin
       gotoxy(28,maxy+3);
       tc(dj2c);tb(8);
       write(djname[2]);
     end;
   end;

begin

  init_max;
  bu:=0;
  ss:=false;
  clrscr;
  print_map;
  print_daoju;
  bf:=false;
  first:=true;

  tc(15);
  if (dela<10) or (level>7) then
   for i:=3 downto 1 do
   begin
     gotoxy(maxx div 2+10,maxy+2);
     writeln(i,'秒后，游戏开始');
     delay(1000);
   end;
  tb(1);
  gotoxy(maxx div 2+10,maxy+2);
  write('═════════════');
  tc(7);
  tb(8);

  repeat
    gotoxy(7,maxy+2);
    tc(15);
    tb(8);
    write(fen);
    gotoxy(7,maxy+3);
    if bu<>999999 then
    begin
      write(bu);
      str(bu,c);
      for i:=1 to 7-length(c)+1 do write(' ');
    end
     else write(999999,'+');
    gotoxy(7,1);
    write(len,'/',max);
    if wf<>maxlongint then
    begin
      gotoxy(35,1);
      tb(8);
      write(' 还剩',wf-fen,'分');
     { gotoxy(47,1);
      tb(1);
      write('══');  }
    end;
    gotoxy(maxx*2-9,1);
    tb(8);
    tc(15);
    if (multiple<10) and (multiple>=0) then write('0');
    write(multiple);
    if bu<999999 then inc(bu);
    gettime(h,m,s,s100);
    tt:=h*360000+m*6000+s*100+s100;
    c:='';
    repeat                   //================================================================================
      if keypressed then
      begin
        c:=upcase(readkey);
        if (c[1] in ['W','A','S','D']) and data.pressbreak then break;
        if c[1]='0' then init_daoju(10);
        if c[1] in ['1'..'9'] then
        begin
          val(c,d);
          init_daoju(d);
        end;
        if c[1] in ['0'..'9'] then
          print_daoju;

        if c='P' then
        begin
          with ttime do
          begin
            gettime(h,m,s,s100);
            t:=h*360000+m*6000+s*100+s100;
            repeat
            until upcase(readkey)='C';
            gettime(h,m,s,s100);
            x:=h*360000+m*6000+s*100+s100;
            inc(bfbt,x-t);
          end;
          continue;
        end;
      end; //end if keypressed

      gettime(h,m,s,s100);
      t:=h*360000+m*6000+s*100+s100;
      if bf then
      begin
        gotoxy(maxx+4-25,maxy+2);
        if t-bfbt>=bfmt then
        begin
          tb(1);
          write('═════════');
          bf:=false;
          gotoxy(bfood.x*2+1,bfood.y+1);
          tb(8);
          write('  ');
        end
         else begin
           tb(8);
           gotoxy(wherex+13,wherey);
           write({'奖励剩余时间:',}(bfmt-t+bfbt) div 100,'.',(bfmt-t+bfbt) mod 100);
         end;
      end;
      if twn<>0 then
      repeat
       // with tipwaiting[1] do
         if t-tipwaiting[1].time.x>=tipwaiting[1].lastfor then
         begin
           d:=tipwaiting[1].time.x;
           gotoxy(13,maxy+2);
           tc(15);
           tb(1);
           for i:=1 to 30 do write('═');
           if bf then
           begin
             tb(8);
             tc(15);
             gotoxy(maxx+4-25,maxy+2);
             write('奖励剩余时间:');
           end;
           for i:=1 to twn-1 do
           begin
             tipwaiting[i]:=tipwaiting[i+1];
             inc(tipwaiting[i].time.x,t-d);
           end;
           dec(twn);
           if twn=0 then
           begin
             break;
           end;
           with tipwaiting[1] do
             tip(s,colour);
           gt(tipwaiting[1].time);

         end;
      until true;

      if daoju[2].appear and (t-daoju[2].time.x>=dj2lf) then
      begin
        daoju[2].appear:=false;
        gotoxy(28,maxy+3);
        tc(7);tb(8);
        write(djname[2]);
      end;

      if dela=-1 then break;
    until (t-tt>dela) or ss; //================================================================================

    ss:=false;
    d:=de;
    if c='' then de:=de
     else case c[1] of
       'W':de:=1;
       'A':de:=4;
       'S':de:=3;
       'D':de:=2;
     end;//end case
    if (de=d) and (c[1] in ['W','A','S','D']) then ss:=true;if data.diis=false then ss:=false;
    if abs(d-de)=2 then
    begin
      de:=d;
    end;
    begin
      if ((de=1) and (d=2)) or ((de=4) and (d=3)) then nc:=3;
      if ((de=2) and (d=3)) or ((de=1) and (d=4)) then nc:=2;
      if ((de=3) and (d=4)) or ((de=2) and (d=1)) then nc:=1;
      if ((de=4) and (d=1)) or ((de=3) and (d=2)) then nc:=4;

      if (de=d) and ((de=1) or (de=3)) then nc:=6;
      if (de=d) and ((de=2) or (de=4)) then nc:=5;
    end;

    xx:=snake[1].x+gox[de];
    yy:=snake[1].y+goy[de];
    tx:=snake[len].x;
    ty:=snake[len].y;
    if ((yy in [1..maxy]=false) or (xx in [1..maxx]=false)) and (level=-1) then
    begin
      if xx<1 then xx:=maxx;
      if xx>maxx then xx:=1;
      if yy<1 then yy:=maxy;
      if yy>maxy then yy:=1;
    end;
    longer:=false;
    if (can(xx,yy,1)=false) then lose:=true;
    if lose then
    begin
      gotoxy(xx*2+1,yy+1);
      tc(12);
      tb(7);
      write('╳');
    end;
    if (can(xx,yy,1)=false) and (xx=snake[len].x) and (yy=snake[len].y) then lose:=false;
     if lose=false then
     begin
       for i:=len downto 2 do
       begin
         snake[i]:=snake[i-1];
         map[snake[i].y,snake[i].x]:=3;
       end;
         gotoxy(snake[1].x*2+1,snake[1].y+1);
         tb(3);
         tc(15);
         write(snakechar[nc]);
       oc:=map[yy,xx];
       snake[1].x:=xx;snake[1].y:=yy;
       map[yy,xx]:=4;
       if ((snake[1].x=food.x) and (snake[1].y=food.y))
        or (daoju[2].appear and (abs(xx-food.x)+abs(yy-food.y)<=4))
       then begin
         gotoxy(food.x*2+1,food.y+1);
         tb(8);
         write('  ');
         longer:=true;
         long(tx,ty);
         pfen;
         init_food(1);
         if (len-4) mod bigfoodappearnumber=0 then init_bfood;
         if random(propappearnum[2])=0 then init_prop(2);
         bu:=0;
       end
       else if (snake[1].x=bfood.x) and (snake[1].y=bfood.y) then
       begin
         longer:=true;
         long(tx,ty);
         bf:=false;
         gotoxy(maxx+4-25,maxy+2);
         tb(1);
         write('═════════');
         bu:=0;
         inc(fen,25);
         if bu<10 then inc(fen,(10-bu)*3);
         bfood.x:=-1;
         bfood.y:=-1;

         if bu<multiplenumber then
         begin
           inc(fen,(multiplenumber-bu)*2);
           inc(multiple);
           if multiple>=propappearnum[1] then
           begin
             if random(dj1jl)=0 then init_prop(1);
           end;
         end else multiple:=0;
       end
       else if isprop(snake[1].x,snake[1].y) then
       begin
         case propnum of
           1:begin
               if random(4)=0 then
               begin
                 longer:=true;
                 long(tx,ty);
               end;
               inc(fen,5);
               for i:=1 to 1000 do
                if (prop[1].zb[i].x=xx) and (prop[1].zb[i].y=yy) then
                begin
                  prop[1].zb[i].x:=-1;
                  prop[1].zb[i].y:=-1;
                  break;
                end;
             end;
         end;//end case
       end;
       if longer then
       begin
        // if
       end
        else begin
          map[ty,tx]:=8;
          gotoxy(tx*2+1,ty+1);
          tb(8);
          write('  ');
        end;
     {  if (xx=tx) and (yy=ty) then
       begin
         gotoxy(xx*2+1,yy+1);
         tb(4);
         write(headchar);
       end;   }

       if ((snake[len].x<>snake[len-1].x) and (snake[len].y=snake[len-1].y))
         then t:=5;
       if ((snake[len].x=snake[len-1].x) and (snake[len].y<>snake[len-1].y))
         then t:=6;

       gotoxy(xx*2+1,yy+1);
       tb(4);
       write(headchar);
       gotoxy(snake[len].x*2+1,snake[len].y+1);
       tb(3);
       write(snakechar[t]);

       if fen>=wf then win:=true;
       if len>=max then break;
     end;  //end if
  until win or lose;
  gotoxy(17,1);
  tb(8);
  if win then
  begin
    tc(12);
    writeln('胜 利！')
  end
  else if lose then
  begin
    tc(10);
    writeln('你 输 了');
  end
  else begin
    tc(12);
    writeln('什么，贪吃蛇也能和局？！');
  end;
  delay(500);
  print_info;
  gotoxy(1,maxy+2);
  tc(12);
  tb(8);
  write('分数：',fen);

  if not gua then
  begin
    t:=fen div 10+random(5*(fen div 200));
    if data.money+t<=maxmoney then
      inc(data.money,fen div 10);
  end;

  gt(ttime);
  d:=ttime.x;
  data.maxfen[11]:=fen;
  if wf=maxlongint then sort;
  if id and (gua=false) then save;
  repeat
    gettime(h,m,s,s100);
    t:=h*360000+m*6000+s*100+s100;
  until (t-d>=100) or (d-t>9000000);
  readkey;
  clrscr;
end;

procedure work;
var n,t,i:longint;

  { procedure save;
   var s:string;
       i,t:longint;
   begin
     assign(wjout,filename+'.dat');
     rewrite(wjout);
     for i:=1 to 10 do
     begin
       s:=zhuan(data.maxfen[i]);
       jia(s);
       writeln(wjout,s);
     end;
     s:=zhuan(data.maxlevel);
     jia(s);
     writeln(wjout,s);
     close(wjout);
   end;       }

begin
  repeat//==============

  clrscr;
  n:=inputn('经典模式'+ln+
            '选关模式'+ln+
            '闯关模式'+ln+
            '  返回');
  clrscr;
  clean_map;
  level:=0;
  if n=4 then exit;
  if (n=1) or (n=2) then
  begin
    if n=2 then
    begin
      level:=inputint('请输入要进入第几关'+ln+
                      '（0:地球是圆的）',0,10,1);
      if level=-1 then continue;
      iz(level-1);
      clrscr;
      if level=0 then level:=-1;
    end else level:=1;
    init_snake;
    init_food(0);
    dela:=inputint('请输入蛇的速度'+ln+ln+
                   '100:Single Cell'+ln+
                   '50 :呵呵'+ln+
                   '30 :一般'+ln+
                   '15 :正常'+ln+
                   '10 :厉害'+ln+
                   '4  :牛×'+ln+
                   '-1 :神 (蛇长>50且非长按)',-1,100,0);
    wf:=maxlongint;
    play;
    exit;
  end;
  if n<>3 then exit;//====================================================
  level:=1;
  wf:=0;
  fen:=0;
  repeat
    clrscr;
    dela:=50-level*5+5;
    if dela<15 then dela:=15;
    wf:=level*150+wf;
    tc(12);
    writeln('第',level,'关');
    delay(300);
    tc(7);
    writeln('本关共需要',wf,'分才能过关');
    writeln('速度：',dela);
    writeln;
    delay(300);
    writeln('请按任意键开始本关');

    clean_map;
    iz(level-1);
    init_snake;
    init_food(0);
    readkey;
    win:=false;
    play;
    if (level>data.maxlevel) and (gua=false) then data.maxlevel:=level;
    if data.money+(level-1)*7<=maxmoney then
      inc(data.money,(level-1)*7);
    inc(level);
  until (level=10+1) or lose;
  dec(level,2);
  if lose then
  begin
    tc(10);
    writeln('闯关失败！');
    delay(300);
    tc(12);
    writeln('分数：',fen);
    delay(1000);
    readkey;
    clrscr;
    exit;
  end;
  if data.money+200<=maxmoney then
    inc(data.money,200);

  tc(12);
  writeln('恭喜你闯关成功！');
  tc(7);
  delay(1000);
  delay(fen);
  readkey;
  clrscr;
  exit;


  until false;//==============
end;

procedure shop;
var n,i,j,t,w:longint;

   function inputn_s(s:ansistring;l,r,m:longint):longint;  //m=1:买    m=2:卖
   var i,n:longint;
      st:string;
   begin
     i:=0;
     repeat
       clrscr;
       tc(7);
       write('现有金钱:');
       tc(14);
       write(moneychar);
       tc(15);
       writeln(data.money);
       tc(7);
       writeln;
       for i:=1 to maxdaoju do
        with daoju[i] do if djname[i]<>'' then
        begin
          tc(15);
          write(i);
          tc(7);
          write(djname[i],':拥有',num,'个');
          gotoxy(20,wherey);tc(14);write(moneychar);tc(15);
          if m=1 then write(djprice[i]);
          if m=2 then write(trunc(djprice[i]*0.9));
          writeln;
        end;
       writeln;

       tc(7);
       inputn_s:=200;
       i:=1;
       writeln(s);
       cursoron;
       readln(st);
       tc(7);
       cursoroff;
       val(st,inputn_s,n);
       if st='-1' then exit(-1);
     until (n=0) and (inputn_s>=l) and (inputn_s<=r);
   end;

begin
  repeat
    clrscr;
    tb(8);
    t:=inputn('购买道具'+ln+
              '出售道具'+ln+
              '  返回');
    if t=3 then break;
    clrscr;
    case t of
      1:begin
          repeat
            repeat
              n:=inputn_s('请输入要购买第几种道具【输入-1返回】',1,maxdaoju,1);
              if n=-1 then break;
              clrscr;
            until {(() and ()) and }((data.money>=djprice[n])  and (djname[n]<>''));
            if n=-1 then break;

            inc(daoju[n].num);
            dec(data.money,djprice[n]);
            clrscr;
          until false;
        end;  //end case 1
      2:begin
          repeat
            repeat
              n:=inputn_s('请输入要出售第几种道具【输入-1返回】',1,maxdaoju,2);
              if n=-1 then break;
              clrscr;
            until (daoju[n].num>=1) and (djname[n]<>'');
            if n=-1 then break;

            if data.money+trunc(djprice[n]*0.9)<=maxmoney then
            begin
              if god=false then dec(daoju[n].num);
              inc(data.money,trunc(djprice[n]*0.9));
            end;
            clrscr;
          until false;
        end; //end case 2
    end;
    if id then
    begin
      clrscr;
      writeln('Saving...');
      save;
    end;
  until false;
end;

procedure setting;
var i,n,t,w:longint;
begin
  with data do
  repeat
    clrscr;
    tb(8);
    t:=inputint('若要在按下方向按键时取消当前的等待，请输入1; 否则请输入2'+ln+
                '若要在按下的方向按键与当前方向相同时取消下一步的等待，请输入3; 否则请输入4',1,4,1);
    if t=-1 then break;
    clrscr;
    case t of
      1:begin
          pressbreak:=true;
        end;  //end case 1
      2:begin
          pressbreak:=false;
        end;  //end case 2
      3:begin
          diis:=true;
        end;  //end case 3
      4:begin
          diis:=false;
        end;  //end case 4
    end;
    tc(12);
    writeln('设置成功');
    delay(300);
  until false;
  clrscr;
  tc(7);
  writeln('Saving...');
  save;
  clrscr;
end;

procedure tuichu;
var i:longint;
begin
  cursoroff;
  clrscr;

  if id then
  begin
    tc(7);
    tb(8);
    writeln('Saving...');
    save;
  end;
  clrscr;


  tc(15);
  writeln('感谢您的使用，您的支持就是对制作者最大的鼓励');writeln;
  print_logo;
  gotoxy(1,21);
  tc(8);write('                                                                By ');tc(15);writeln('Fallen_Breath');
  tc(8);write('                                                                   Version ');tc(15);writeln(version);
  writeln('                                                                    ',date);
  i:=5;
  tc(7);
  gotoxy(1,24);
  write('                              本游戏将在',i,'秒后退出');
  repeat
    gotoxy(41,wherey);
    write(i);
    delay(1000);
    dec(i);
  until i=0;
  gotoxy(41,wherey);
  write(i);
  halt;
end;

BEGIN
  init_main;
  repeat
    clrscr;print_logo;
    tc(7);gotoxy(35,20);
    t:=inputn('登录'+ln+
              '游客');
    case t of
      1:begin id:=true;load;if id=false then continue;end;
      2:id:=false;
    end;
  break;until false;

  clrscr;
  if id=false then
  begin
    tc(12);
    writeln('未登录！');
    delay(1000);
    tc(7);
    clrscr;
  end;

  oldmoney:=data.money;
  t1:=1;
  repeat
    init_game;
    clrscr;
    if (data.money>oldmoney) and (t1<>1) then
    begin
      tc(14);
      writeln('金钱增加 ',data.money-oldmoney,moneychar);
      delay(500);
      readkey;
      clrscr;
    end;
    t1:=0;
    tc(7);
    tb(8);
    if id then t:=inputn(' 开始游戏'+ln+
                         '   退出'+ln+
                         '   商店'+ln+
                         '查看高分榜'+ln+
                         '   设置')
     else t:=inputn('   游戏'+ln+
                    '   退出'+ln+
                    '   商店'+ln+
                    '查看高分榜'+ln+
                    '   登录');
    clrscr;
    oldmoney:=data.money;
    case t of
      1:work;
      2:tuichu;
      3:shop;
      4:print_max_fen;
      5:if id then setting
         else begin
           id:=true;
           load;
           t1:=1;
         end;
    end;
  until false;
END.
