set pa=%cd%
PATH=%cd%\..\..\protogen-net;%cd%

protogen -i:common.proto -o:common.cs
protogen -i:login.proto -o:login.cs
protogen -i:user.proto -o:user.cs
protogen -i:sums.proto -o:sums.cs
protogen -i:vips.proto -o:vips.cs
protogen -i:task.proto -o:task.cs
protogen -i:dailys.proto -o:dailys.cs
protogen -i:charge.proto -o:charge.cs
protogen -i:ctor.proto -o:ctor.cs
protogen -i:unit.proto -o:unit.cs
protogen -i:prop.proto -o:prop.cs
protogen -i:equip.proto -o:equip.cs
protogen -i:store.proto -o:store.cs
protogen -i:stall.proto -o:stall.cs
protogen -i:field.proto -o:field.cs
protogen -i:brief.proto -o:brief.cs
protogen -i:chat.proto -o:chat.cs
protogen -i:inform.proto -o:inform.cs
protogen -i:notice.proto -o:notice.cs
protogen -i:friend.proto -o:friend.cs
protogen -i:shield.proto -o:shield.cs
protogen -i:forum.proto -o:forum.cs
protogen -i:fight.proto -o:fight.cs
protogen -i:resbuy.proto -o:resbuy.cs

copy *.cs ..\..\..\Client\Game\Assets\Script\Application\Game\Net\Proto\
