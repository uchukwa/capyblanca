unit BoardViewerUnit;

interface                                   

uses
  ExternalMemoryUnit,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, StdCtrls;


Const BoardSize=400;

type

  TBoardViewerWindow = class(TForm)
    Board: TImage;
    Button1: TButton;
    procedure Make(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


  TDistanceI = class
                 Origin,Dest: Tsquare;
                 piecetp:TPiecetype;
                 Distance:Integer;
               end;

  TDistance0 = Class (TDistanceI)
                  Trajectory: Array [0..64] {linear list is better} of Tposition;
               end;



procedure dist_trajectory_search(Piecetype:TPiecetype; Orig:TPosition; Dest:TPosition);
procedure Drawsquare (Canvas:Tcanvas; x,y: integer);
Procedure DrawSquareName(Canvas:TCanvas;x1,y1:integer);
Procedure Drawshadow (Canvas:TCanvas; x,y: integer);


var
  BoardViewerWindow: TBoardViewerWindow;        

implementation

{$R *.DFM}


procedure dist_trajectory_search(Piecetype:TPiecetype; Orig:TPosition; Dest:TPosition);
var k,t,min:integer;
begin
     (* This procedure implements a shortest path on the graph induced by a piecetype, its
     origin square, and its destination square.  See Robert Sedgewick's "algorithms in C++"
     Addison-Wesley, 1992, for full details *)

     (* the sign of a val entry indicates if the corresponding vertex (square) is on
     the actual tree (i.e., potential trajectory), or if it is on the priority queue.
     All vertices (squares) start at the priority queue and have sentinel priority
     unseen; To change the priority of the vertex, we simply assign the new priority
     to the val entry for that vertex (square).  To remove the highest-priority vertex,
     we scan through the val array to find the vertex with largest negative (closest to
     zero) value, then complement its val entry.*)

     (*we must update its logic to take full advantadge of chess topology.  We have to
     use priority-first search, but we must set the priority of each fringe vertex
     encountered to the distance in the tree from x(origin) to the fringe vertex plus the d-1
     distance from the fringe vertex to y(destination). This will make the algorithm
     always go towards the destination, and only backtrack when roadblocks are reached.*)

     (*another change we must do is make the algorithm block squares which contain pieces,
     or which contains threats, etc. They simply should not be searched.*)
 {
     t:=0; min:=0;       (*Phase 1. Initialize priorities*)
     for k:=1 to V-1 do
     begin
         val[k]=unseen;   (*All vertices are unseen*)
         dad[k]:=0;
     end;

     val[0]:=unseen-1;

     k:=1;
     While (k<>0) do
     begin

          val[k] = -val[k];  (*All vertices are on the priority list*)
          if (val[k]=-unseen) then val[k]:=0;   (*?*)

          for t:=1 to V-1 do
              if (val[t]<0) then  (*if vertex (square) has not been transversed...*)
              begin
                   if (val[t]<-priority) and (a[k,t]>0) then
                   begin
                        val[t]=-priority;
                        dad[t]:=k;
                   end;

                   if (val[t]>val[min]) then min:=t;
              end;

          k:=min;
          min:=0;
     end;}
end;




Procedure Drawsquare (Canvas:TCanvas; x,y: integer);
var z:integer; Color:TColor;
begin
     Z:=Boardsize div 8;
     if ((x+y) mod 2)=1 then Color:= clDkGray else color:= clltGray;
     Canvas.Brush.Color:=Color;
     Canvas.Pen.Color:=Color;
     Canvas.rectangle(x*z,y*z,(x+1)*z-1,(y+1)*z-1);

     Canvas.MoveTo(x*z-1,y*z-1);
     Canvas.LineTo(x*z-1,(y+1)*z-1);
     Canvas.LineTo((x+1)*z-1,(y+1)*z-1);
     Canvas.LineTo((x+1)*z-1,y*z-1);
     Canvas.LineTo(x*z-1,y*z-1);
end;

Procedure Drawshadow (Canvas:Tcanvas; x,y: integer);
var z:integer; Color:TColor;
begin
     Z:=Boardsize div 8;
     if ((x+y) mod 2)=0 then Color:= clDkGray else color:= clltGray;
     Canvas.Brush.Color:=Color;
     Canvas.Pen.Color:=Color;
     Canvas.ellipse(x*z+15,y*z+10,(x+1)*z-16,(y+1)*z-11);
end;


Procedure DrawSquareName(Canvas:TCanvas;x1,y1:integer);
var z1:integer; Color:Tcolor;
begin
     Z1:=Boardsize div 8;

     if ((x1+y1) mod 2)=1 then
     begin
          canvas.Font.Color := clblack;
     end else
     begin
          canvas.Font.Color := clBlack;
     end;
     Canvas.brush.style := bsClear;
     Canvas.textout(x1*z1+1,y1*z1+1,convertsquare(x1+1,y1+1));
     canvas.Font.Color := clwhite;
     Canvas.textout(x1*z1,y1*z1,convertsquare(x1+1,y1+1));
end;


procedure TBoardViewerWindow.Make(Sender: TObject);
Var P:Array[1..32] of TPiece; Pos:Tsquare;
    x,y, Z: integer; White_Rook_Bitmap, Black_Queen_bitmap: TBitmap;
begin
     Z:=Boardsize div 8;

     for x:= 0 to 7 do
         for y:= 0 to 7 do
         begin
              Board.Canvas.Brush.Color:=Color;
              Board.Canvas.Pen.Color:=Color;
              Board.Canvas.rectangle(x*z,y*z,(x+1)*z-1,(y+1)*z-1);
              Drawsquare(Board.canvas,x,y);
         end;
     Board.Canvas.Pen.Color:=clWhite;
     Board.Canvas.Brush.Color:=clWhite;

     Pos.X:=1;Pos.Y:=1;
     P[1]:=Tpiece.create (Pos,true,knight);
     P[1].display (Board.Canvas);

     Pos.X:=8;Pos.Y:=5;
     P[2]:=Tpiece.create (Pos,false,knight);
     P[2].display (Board.Canvas);

     Pos.X:=8;Pos.Y:=8;
     P[3]:=Tpiece.create (Pos,true,pawn);
     P[3].display (Board.Canvas);

     Pos.X:=3;Pos.Y:=1;
     P[4]:=Tpiece.create (Pos,true,king);
     P[4].display (Board.Canvas);

     Pos.X:=5;Pos.Y:=8;
     P[5]:=Tpiece.create (Pos,False,rook);
     P[5].display (Board.Canvas);

     Pos.X:=2;Pos.Y:=7;
     P[6]:=Tpiece.create (Pos,False,Bishop);
     P[6].display (Board.Canvas);
end;

procedure TBoardViewerWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     {how do I uncheck the window mark here?}
end;

end.                      
