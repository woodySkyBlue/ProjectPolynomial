unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Math, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TArrayOfDouble = array of Double;
  TArrayOfArrayOfDouble = array of array of Double;

  TSinPolyData = record
    X, Y: Double;
  end;

  TSinFitOrder = (sporFitOrder1, sporFitOrder2, sporFitOrder3);
  TSinCalcSide = (sditLarge, sditSmall);

  TSinPoly = record
  private
    FDataX, FDataY: array of Double;
    FMaxFitOrder: TSinFitOrder;
    // Polynomial用メソッド
    function ProcLinear: TArrayOfDouble;
    function ProcGauss(AGauss: TArrayOfArrayOfDouble): TArrayOfDouble;
    function ProcPolyfit(AOrder: TSinFitOrder): TArrayOfDouble;
    //function ProcPolyValue(AOrder: TSinFitOrder; AValue: Double): Double;
    function ProcPolyOrder1Value(AValue: Double): Double;
    function ProcPolyOrder2Value(AValue: Double): Double;
    function ProcPolyOrder3Value(AValue: Double): Double;
    function ProcPolyOrder1Fit: TArrayOfDouble;
    function ProcPolyOrder2Fit: TArrayOfDouble;
    function ProcPolyOrder3Fit: TArrayOfDouble;
    // Root用メソッド
    function ProcRootBase(Ax, Ab, Ac, Ad: Double): Double;
    function ProcRootPrime(Ax, Ab, Ac: Double): Double;
    function ProcRootNewton(Ax, Ab, Ac, Ad: Double): Double;
    function ProcRootOrder1(ATargetValue: Double): TArrayOfDouble;
    function ProcRootOrder2(ATargetValue: Double): TArrayOfDouble;
    function ProcRootOrder3(ATargetValue: Double): TArrayOfDouble;
    // プロパティ用メソッド
    function GetMaxFitOrder: TSinFitOrder;
    function GetCount: Integer;
  public
    function Polyfit: TArrayOfDouble;
    //function PolyValue(AOrder: TSinFitOrder; AValue: Double): Double;
    function PolyValue(AValue: Double): Double;
    function RootValue(ATargetValue: Double): TArrayOfDouble;
    function TryRootValue(ATargetValue, ABaseValue: Double; ASide: TSinCalcSide; var ARetValue: Double): Boolean;
    procedure Add(AData: TSinPolyData); overload;
    procedure Add(AValueX, AValueY: Double); overload;
    procedure Clear;
    property MaxFitOrder: TSinFitOrder read GetMaxFitOrder write FMaxFitOrder;
    property Count: Integer read GetCount;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
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
  FArrayX[0] := 1;  FArrayY[0] := 30;
  FArrayX[1] := 2;  FArrayY[1] := 15;
  FArrayX[2] := 3;  FArrayY[2] := 30;
  FArrayX[3] := 4;  FArrayY[3] := 40;
  FArrayX[4] := 5;  FArrayY[4] := 55;
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
  FValue: Double;
begin
　F.Clear;
  F.MaxFitOrder := sporFitOrder3;
  F.Add(1, 30);
  F.Add(2, 15);
  F.Add(3, 30);
  F.Add(4, 40);
//  F.Add(5, 55);

//  var R := F.Polyfit;
//  for var Cnt := High(R) downto 0 do Memo1.Lines.Add(Format('R[%d]=%g', [Cnt, R[Cnt]]));

//  Memo1.Lines.Add(Format('f(%g)=%g', [0.0, F.PolyValue(0.0)]));
//  Memo1.Lines.Add(Format('f(%g)=%g', [1.0, F.PolyValue(1.0)]));
//  Memo1.Lines.Add(Format('f(%g)=%g', [2.0, F.PolyValue(2.0)]));
//  Memo1.Lines.Add(Format('f(%g)=%g', [3.0, F.PolyValue(3.0)]));
//  Memo1.Lines.Add(Format('f(%g)=%g', [4.0, F.PolyValue(4.0)]));
//  Memo1.Lines.Add(Format('f(%g)=%g', [5.0, F.PolyValue(5.0)]));
//  Memo1.Lines.Add(Format('f(%g)=%g', [6.0, F.PolyValue(6.0)]));

//  var R := F.RootValue(StrToFloatDef(Edit1.Text, 0.0));
//  for var Cnt := 0 to High(R) do Memo1.Lines.Add(Format('y=%g', [R[Cnt]]));

  var FT := StrToFloatDef(Edit1.Text, 0.0);
  var FB := StrToFLoatDef(Edit2.Text, 0.0);
  if F.TryRootValue(FT, FB, sditSmall, FValue) then
    Memo1.Lines.Add(Format('x=%g', [FValue]))
  else
    Memo1.Lines.Add('None');
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

function TSinPoly.PolyValue(AValue: Double): Double;
begin
  Result := 0.0;
  case Self.FMaxFitOrder of
    sporFitOrder1: Result := ProcPolyOrder1Value(AValue);
    sporFitOrder2: Result := ProcPolyOrder2Value(AValue);
    sporFitOrder3: Result := ProcPolyOrder3Value(AValue);
  end;
end;

function TSinPoly.RootValue(ATargetValue: Double): TArrayOfDouble;
begin
  SetLength(Result, 0);
  case Self.FMaxFitOrder of
    sporFitOrder1: Result := ProcRootOrder1(ATargetValue);
    sporFitOrder2: Result := ProcRootOrder2(ATargetValue);
    sporFitOrder3: Result := ProcRootOrder3(ATargetValue);
  end;
end;

function TSinPoly.TryRootValue(ATargetValue, ABaseValue: Double; ASide: TSinCalcSide; var ARetValue: Double): Boolean;
var
  FData: TArrayOfDouble;
begin
  Result := False;
  if Self.Count > 1 then begin
    SetLength(FData, 0);
    case Self.FMaxFitOrder of
      sporFitOrder1: FData := ProcRootOrder1(ATargetValue);
      sporFitOrder2: FData := ProcRootOrder2(ATargetValue);
      sporFitOrder3: FData := ProcRootOrder3(ATargetValue);
    end;
    if ASide = sditLarge then
      // ABaseValueよりも大きなRoot値を見つける
      for var Cnt := 0 to High(FData) do begin
        if FData[Cnt] > ABaseValue then begin
          Result := True;
          ARetValue := FData[Cnt];
          Exit;
        end;
      end
    else
      // ABaseValueよりも小さなRoot値を見つける
      for var Cnt := High(FData) downto 0 do begin
        if FData[Cnt] < ABaseValue then begin
          Result := True;
          ARetValue := FData[Cnt];
          Exit;
        end;
      end;
  end;
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

function TSinPoly.GetMaxFitOrder: TSinFitOrder;
begin
  Result := sporFitOrder2;
  if Self.FMaxFitOrder in [sporFitOrder1..sporFitOrder3] then Result := FMaxFitOrder;
end;

function TSinPoly.Polyfit: TArrayOfDouble;
begin
  SetLength(Result, 0);
  case Self.FMaxFitOrder of
    sporFitOrder1: Result := ProcPolyOrder1Fit;
    sporFitOrder2: Result := ProcPolyOrder2Fit;
    sporFitOrder3: Result := ProcPolyOrder3Fit;
  end;
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

function TSinPoly.ProcPolyOrder1Value(AValue: Double): Double;
begin
  Result := 0.0;
  if Self.Count > 1 then begin
    var F := ProcPolyfit(sporFitOrder1);
    Result := AValue * F[1] + F[0];
  end;
end;

function TSinPoly.ProcPolyOrder2Value(AValue: Double): Double;
begin
  if Self.Count > 2 then begin
    var F := ProcPolyfit(sporFitOrder2);
    Result := F[2] * Sqr(AValue) + F[1] * AValue + F[0];
  end
  else begin
    Result := Self.ProcPolyOrder1Value(AValue);
  end;
end;

function TSinPoly.ProcPolyOrder3Value(AValue: Double): Double;
begin
  if Self.Count > 3 then begin
    var F := ProcPolyfit(sporFitOrder3);
    Result := F[3] * Power(AValue, 3) + F[2] * Sqr(AValue) + F[1] * AValue + F[0];
  end
  else begin
    Result := Self.ProcPolyOrder2Value(AValue);
  end;
end;

function TSinPoly.ProcRootBase(Ax, Ab, Ac, Ad: Double): Double;
begin
  // x^3+bx^2+cx+d
  Result := ((Ab + Ax) * Ax + Ac) * Ax + Ad;
end;

function TSinPoly.ProcRootPrime(Ax, Ab, Ac: Double): Double;
begin
  // 3x^2+2bx+c (f()の導関数)
  Result := (2 * Ab + 3 * Ax) * Ax + Ac;
end;

function TSinPoly.ProcRootNewton(Ax, Ab, Ac, Ad: Double): Double;
begin
  while true do begin
    var Fx := ProcRootBase(Ax, AB, AC, AD);
    var Fp := ProcRootPrime(Ax, AB, AC);
    if Fp = 0 then Fp := 1;
    var Fxprev := Ax;
    Ax := Ax - (Fx / Fp);
    if SameValue(Ax, Fxprev, 1E-15) then Break;
  end;
  Result := Ax;
end;

function TSinPoly.ProcRootOrder1(ATargetValue: Double): TArrayOfDouble;
var
  FData: TArrayOfDouble;
begin
  SetLength(Result, 0);
  FData := ProcPolyOrder1Fit;
  if (Length(FData) = 2) and (FData[0] <> 0) then begin
    SetLength(Result, 1);
    Result[0] := (ATargetValue - FData[0]) / FData[1];
  end;
end;

function TSinPoly.ProcRootOrder2(ATargetValue: Double): TArrayOfDouble;
var
  FData: TArrayOfDouble;        // Fa->2 Fb->1 Fc->0
  FList: TList<Double>;
begin
  SetLength(Result, 0);
  FData := ProcPolyOrder2Fit;
  if Length(FData) < 3 then
    Result := ProcRootOrder1(ATargetValue)
  else if Length(FData) = 3 then begin
    var FValue := Sqr(FData[1])-4*FData[2]*(FData[0]-ATargetValue);
    if FValue >= 0 then begin
      SetLength(Result, 2);
      FList := TList<Double>.Create;
      try
        FList.Add((-FData[1]+Sqrt(FValue)) / (2*FData[2]));
        FList.Add((-FData[1]-Sqrt(FValue)) / (2*FData[2]));
        FList.Sort;
        for var Cnt := 0 to High(Result) do Result[Cnt] := FList[Cnt];
      finally
        FList.Free;
      end;
    end;
  end;
end;

function TSinPoly.ProcRootOrder3(ATargetValue: Double): TArrayOfDouble;
var
  FData: TArrayOfDouble;       // Fa->3 Fb->2 Fc->1  Fd->0
  FList: TList<Double>;
  FA, FB, FC, FD: Double;
begin
  SetLength(Result, 0);
  FData := ProcPolyOrder3Fit;
  if Length(FData) < 4 then
    Result := ProcRootOrder2(ATargetValue)
  else if Length(FData) = 4 then begin
    FD := FData[0]-ATargetValue;
    FB := FData[2] / FData[3];
    FC := FData[1] / FData[3];
    FD := FD / FData[3];
    FA := FB*FB-3*FC;
    if FA > 0 then begin
      FList := TList<Double>.Create;
      try
        FA := 2*Sqrt(FA)/3;
        FList.Add(ProcRootNewton(-FA-FB/3, FB, FC, FD));
        FList.Add(ProcRootNewton( FA-FB/3, FB, FC, FD));
        if FList[0] <> FList[1] then begin
          FList.Add(ProcRootNewton(FB/(-3), FB, FC, FD));
          FList.Sort;
          SetLength(Result, 3);
          for var Cnt := 0 to High(Result) do Result[Cnt] := FList[Cnt];
        end
        else begin
          SetLength(Result, 1);
          Result[0] := FList[0];
        end;
      finally
        FList.Free;
      end;
    end
    else begin
      SetLength(Result, 1);
      Result[0] := ProcRootNewton(0, FB, FC, FD);
    end;
  end;
end;

function TSinPoly.ProcPolyOrder1Fit: TArrayOfDouble;
begin
  SetLength(Result, 0);
  if Self.Count > 1 then begin
    Result := ProcPolyfit(sporFitOrder1);
  end;
end;

function TSinPoly.ProcPolyOrder2Fit: TArrayOfDouble;
begin
  if Self.Count > 2 then
    Result := ProcPolyfit(sporFitOrder2)
  else
    Result := Self.ProcPolyOrder1Fit;
end;

function TSinPoly.ProcPolyOrder3Fit: TArrayOfDouble;
begin
  if Self.Count > 3 then
    Result := ProcPolyfit(sporFitOrder3)
  else
    Result := Self.ProcPolyOrder2Fit;
end;

end.
