unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TArrayOfDouble = array of Double;
  TArrayOfArrayOfDouble = array of array of Double;

  TSinPolyData = record
    X, Y: Double;
  end;

  TSinFitOrder = (sporFitOrder1, sporFitOrder2, sporFitOrder3);

  TSinPoly = record
  private
    FDataX, FDataY: array of Double;
    function ProcLinear: TArrayOfDouble;
    function ProcGauss(AGauss: TArrayOfArrayOfDouble): TArrayOfDouble;
    function ProcPolyfit(AOrder: TSinFitOrder): TArrayOfDouble;
    function GetCount: Integer;
  public
    function Polyfit(AOrder: TSinFitOrder): TArrayOfDouble;
    function PolyValue(AOrder: TSinFitOrder; AValue: Double): Double;
    procedure Add(AData: TSinPolyData); overload;
    procedure Add(AValueX, AValueY: Double); overload;
    procedure Clear;
    property Count: Integer read GetCount;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure ProcMemoMessage(A: TArrayOfArrayOfDouble);
    procedure Sai(Ax, Ay: TArrayOfDouble; AOrder, ASize: Integer);
    procedure Gauss(var AGauss: TArrayOfArrayOfDouble);
    procedure Linear(Ax, Ay: TArrayOfDouble; ASize: Integer);

    function Polyfit(Ax, Ay: TArrayOfDouble; AOrder, ASize: Integer): TArrayOfDouble;
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses UnitUtils;

procedure TForm1.Button1Click(Sender: TObject);
var
  FArrayX, FArrayY: TArrayOfDouble;
  FGaussArray: TArrayOfArrayOfDouble;
begin
  var FOrder := 2+1;      // 次数=2     N01
  var FDataSize := 5;     // データ数=3 Sin S01
  SetLength(FArrayX, FDataSize);
  SetLength(FArrayY, FDataSize);
  FArrayX[0] := 1;  FArrayY[0] := 10;
  FArrayX[1] := 2;  FArrayY[1] := 15;
  FArrayX[2] := 3;  FArrayY[2] := 30;
  FArrayX[3] := 4;  FArrayY[3] := 40;
  FArrayX[4] := 5;  FArrayY[4] := 20;
  //Sai(FArrayX, FArrayY, FOrder, FDataSize);
  //Linear(FArrayX, FArrayY, FDataSize);
  var F := Polyfit(FArrayX, FArrayY, 3, 5);
  for var i := 0 to High(F) do
    Memo1.Lines.Add(Format('a%d=%g', [i, F[i]]));
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  F: TSinPoly;
  FData: TSinPolyData;
  FList: TUnitDataList;
begin
//  FData.X := 1; FData.Y := 10; F.Add(FData);
//  FData.X := 2; FData.Y := 15; F.Add(FData);
//  FData.X := 3; FData.Y := 30; F.Add(FData);
//  FData.X := 4; FData.Y := 40; F.Add(FData);
//  FData.X := 5; FData.Y := 20; F.Add(FData);
  F.Add(1, 10);
  F.Add(2, 15);
  F.Add(3, 30);
  F.Add(4, 40);
  F.Add(5, 20);
  //var R := F.Polyfit(sporFitOrder2);
  //for var Cnt := 0 to High(R) do Memo1.Lines.Add(R[Cnt].ToString);
  FList.Clear;
  for var Cnt := 0 to 10 do FList.Add(F.PolyValue(sporFitOrder1, Cnt), 3);
  Memo1.Lines.Add(FList.TabText);
  FList.Clear;
  for var Cnt := 0 to 10 do FList.Add(F.PolyValue(sporFitOrder2, Cnt), 3);
  Memo1.Lines.Add(FList.TabText);
  FList.Clear;
  for var Cnt := 0 to 10 do FList.Add(F.PolyValue(sporFitOrder3, Cnt), 3);
  Memo1.Lines.Add(FList.TabText);
end;

procedure TForm1.ProcMemoMessage(A: TArrayOfArrayOfDouble);
var
  FList: TUnitDataList;
begin
  Memo1.Lines.Add('**************************************');
  for var ii := 0 to High(A) do begin
    FList.Clear;
    for var jj := 0 to High(A[0]) do FList.Add(A[ii, jj], 3);
    Memo1.Lines.Add(FList.CommaText);
  end;
  Memo1.Lines.Add('**************************************');
end;

function TForm1.Polyfit(Ax, Ay: TArrayOfDouble; AOrder, ASize: Integer): TArrayOfDouble;
var
  FGaussArray: TArrayOfArrayOfDouble;
begin
  SetLength(FGaussArray, AOrder, AOrder+1);
  for var i := 0 to AOrder-1 do
    for var j := 0 to AOrder-1 do
      for var k := 0 to ASize-1 do
        FGaussArray[i, j] := FGaussArray[i, j] + power(Ax[k], i+j);
  for var i := 0 to AOrder-1 do
    for var k := 0 to ASize-1 do
      FGaussArray[i, AOrder] := FGaussArray[i, AOrder] + power(Ax[k], i) * Ay[k];
  Gauss(FGaussArray);
  SetLength(Result, Length(FGaussArray));
  for var i := 0 to High(FGaussArray) do Result[i] := FGaussArray[i, Length(FGaussArray)];
end;

// n次回帰計算用データーの配列割付と、ガウスサブルーチンの呼び出し
procedure TForm1.Sai(Ax, Ay: TArrayOfDouble; AOrder, ASize: Integer);
var
  FGaussArray: TArrayOfArrayOfDouble;
begin
  SetLength(FGaussArray, AOrder, AOrder+1);
  for var i := 0 to AOrder-1 do
    for var j := 0 to AOrder-1 do
      for var k := 0 to ASize-1 do
        FGaussArray[i, j] := FGaussArray[i, j] + power(Ax[k], i+j);
  for var i := 0 to AOrder-1 do
    for var k := 0 to ASize-1 do
      FGaussArray[i, AOrder] := FGaussArray[i, AOrder] + power(Ax[k], i) * Ay[k];
  Gauss(FGaussArray);
end;

procedure TForm1.Gauss(var AGauss: TArrayOfArrayOfDouble);
begin
  for var k := 0 to High(AGauss) do begin
    var FMax := 0.0;
    var FPivot := k;
    for var i := k to High(AGauss) do
      if abs(AGauss[i, k]) > FMax then begin
        FMax := abs(AGauss[i, k]);
        FPivot := i;
      end;
    if FPivot <> k then
      for var j := 0 to High(AGauss[0]) do begin
        var F := AGauss[k, j];
        AGauss[k, j] := AGauss[FPivot, j];
        AGauss[FPivot, j] := F;
      end;
    var F := Agauss[k, k];
    AGauss[k, k] := 1.0;
    for var j := k+1 to High(AGauss[0]) do AGauss[k, j] := AGauss[k, j] / F;
    for var i := 0 to High(AGauss) do
      if k <> i then begin
        var FF := AGauss[i, k];
        AGauss[i, k] := 0;
        for var j := k+1 to High(AGauss[0]) do AGauss[i, j] := AGauss[i, j] - FF * AGauss[k, j];
      end;
  end;
  for var i := 0 to High(AGauss) do
    Memo1.Lines.Add(Format('%g', [AGauss[i, Length(AGauss)]]));
end;

procedure TForm1.Linear(Ax, Ay: TArrayOfDouble; ASize: Integer);
var
  FSumX, FSquareX, FSumY, FSquareY: Extended;
begin
  // 配列内の値の総和と 2 乗和
  SumsAndSquares(Ax, FSumX, FSquareX);
  SumsAndSquares(Ay, FSumY, FSquareY);
  var F := 0.0;
  for var i := 0 to ASize-1 do
    F := F + Ax[i] * Ay[i];
  FSquareX := FSquareX - FSumX * FSumX / ASize;
  F := F - FSumX * FSumY / ASize;
  FSquareY := FSquareY - FSumY * FSumY / ASize;
  var R := 1.0;
  if FSquareX * FSquareY > 0 then
    R := F / Sqrt(FSquareX * FSquareY);
  var Fb := F / FSquareX;
  var Fa := FSumY / ASize - Fb * FSumX / ASize;
  Memo1.Lines.Add('一次回帰計算　Y := bX + a');
  Memo1.Lines.Add(Format('相関係数 r=%g', [R]));
  Memo1.Lines.Add(Format('係数 a=%g', [Fa]));
  Memo1.Lines.Add(Format('係数 b=%g', [Fb]));


end;

{ TSinPoly }

procedure TSinPoly.Add(AData: TSinPolyData);
begin
  Self.Add(AData.X, AData.Y);
end;

procedure TSinPoly.Add(AValueX, AValueY: Double);
begin
  SetLength(FDataX, Self.Count+1);
  SetLength(FDataY, Self.Count+1);
  FDataX[Self.Count-1] := AValueX;
  FDataY[Self.Count-1] := AValueY;
end;

function TSinPoly.PolyValue(AOrder: TSinFitOrder; AValue: Double): Double;
begin
  Result := 0.0;
  var F := ProcPolyfit(AOrder);
  case AOrder of
    sporFitOrder1: Result := AValue * F[1] + F[0];
    sporFitOrder2: Result := F[2] * Sqr(AValue) + F[1] * AValue + F[0];
    sporFitOrder3: Result := F[3] * Power(AValue, 3) + F[2] * Sqr(AValue) + F[1] * AValue + F[0];
  end;
//  var F1 := F[2] * Power(AValue, 2);
//  var F2 := F[1] * Sqr(AValue);
//  var F3 := F[0];
//  Result := F1 + F2 + F3;
end;

procedure TSinPoly.Clear;
begin
  SetLength(FDataX, 0);
  SetLength(FDataY, 0);
end;

function TSinPoly.GetCount: Integer;
begin
  Result := Length(FDataY);
end;

function TSinPoly.Polyfit(AOrder: TSinFitOrder): TArrayOfDouble;
begin
  Result := ProcPolyfit(AOrder);
end;

function TSinPoly.ProcLinear: TArrayOfDouble;
var
  FSumX, FSquareX, FSumY, FSquareY: Extended;
begin
  // 配列内の値の総和と 2 乗和
  SumsAndSquares(FDataX, FSumX, FSquareX);
  SumsAndSquares(FDataY, FSumY, FSquareY);
  var F := 0.0;
  for var i := 0 to Self.Count-1 do
    F := F + FDataX[i] * FDataY[i];
  FSquareX := FSquareX - FSumX * FSumX / Self.Count;
  F := F - FSumX * FSumY / Self.Count;
  FSquareY := FSquareY - FSumY * FSumY / Self.Count;
  SetLength(Result, 2);
  Result[1] := F / FSquareX;
  Result[0] := FSumY / Self.Count - Result[1] * FSumX / Self.Count;
end;

function TSinPoly.ProcGauss(AGauss: TArrayOfArrayOfDouble): TArrayOfDouble;
begin
  for var k := 0 to High(AGauss) do begin
    var FMax := 0.0;
    var FPivot := k;
    for var i := k to High(AGauss) do
      if abs(AGauss[i, k]) > FMax then begin
        FMax := abs(AGauss[i, k]);
        FPivot := i;
      end;
    if FPivot <> k then
      for var j := 0 to High(AGauss[0]) do begin
        var F := AGauss[k, j];
        AGauss[k, j] := AGauss[FPivot, j];
        AGauss[FPivot, j] := F;
      end;
    var F := Agauss[k, k];
    AGauss[k, k] := 1.0;
    for var j := k+1 to High(AGauss[0]) do AGauss[k, j] := AGauss[k, j] / F;
    for var i := 0 to High(AGauss) do
      if k <> i then begin
        var FF := AGauss[i, k];
        AGauss[i, k] := 0;
        for var j := k+1 to High(AGauss[0]) do AGauss[i, j] := AGauss[i, j] - FF * AGauss[k, j];
      end;
  end;
  SetLength(Result, Length(AGauss));
  for var i := 0 to High(AGauss) do Result[i] := AGauss[i, Length(AGauss)];
end;

function TSinPoly.ProcPolyfit(AOrder: TSinFitOrder): TArrayOfDouble;
var
  FGaussArray: TArrayOfArrayOfDouble;
begin
  if AOrder = sporFitOrder1 then begin
    // 一次直線回帰
    Result := ProcLinear;
  end
  else begin
    // n次回帰
    var FOrder := Ord(AOrder)+2;
    SetLength(FGaussArray, FOrder, FOrder+1);
    for var i := 0 to FOrder-1 do
      for var j := 0 to FOrder-1 do
        for var k := 0 to Self.Count-1 do
          FGaussArray[i, j] := FGaussArray[i, j] + power(FDataX[k], i+j);
    for var i := 0 to FOrder-1 do
      for var k := 0 to Self.Count-1 do
        FGaussArray[i, FOrder] := FGaussArray[i, FOrder] + power(FDataX[k], i) * FDataY[k];
    Result := ProcGauss(FGaussArray);
  end;
end;

end.
