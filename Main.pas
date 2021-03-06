unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.ImageList, FMX.ImgList, FMX.ListView, FMX.StdCtrls,
  FMX.Controls.Presentation, Json, System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient;

type
  TMainForm = class(TForm)
    ToolBar1: TToolBar;
    RefreshBtn: TButton;
    Label1: TLabel;
    MainListView: TListView;
    ImageList1: TImageList;
    procedure RefreshBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    currencygetaddress:string;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

// ??????? ??? ???????? ??????? ?? ?????? ? ????????? ?????? ?? ????????? http
function idHttpGet(const aURL: string): string;
// uses  System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient;
var
  Resp: TStringStream;
  Return: IHTTPResponse;
begin
  Result := '';
  with TNetHTTPClient.Create(nil) do
  begin
    Resp := TStringStream.Create('', TEncoding.ANSI);
    Return := Get( { TURI.URLEncode } (aURL), Resp);
    Result := Resp.DataString;
    Resp.Free;
    Free;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  currencygetaddress:='https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5';
end;

procedure TMainForm.RefreshBtnClick(Sender: TObject);
var responsejson:string; JSON:TJSONObject; JSONMyArr:TJSONArray; i:integer;
begin

  MainListView.Items.Clear;

  responsejson:=idHttpGet(currencygetaddress);
  responsejson:='{"mainarr":'+responsejson+'}';

  JSON := TJSONObject.ParseJSONValue(responsejson) as TJSONObject;
  JSONMyArr:=TJSONArray(JSON.Get('mainarr').JsonValue);
  FormatSettings.DecimalSeparator:='.';

  for i:=0 to JSONMyArr.Size-1 do
  begin
    MainListView.Items.Add.Text:='???? ????? ?? ????????? ? UAH'+#13#10+#13#10+#13#10+#13#10;

    if (TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('base_ccy')).JsonValue.Value)='USD' then
      begin
         MainListView.Items[i].Detail:='??? ??????: '+(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('ccy')).JsonValue.Value)+#13#10+
          '??? ???????????? ??????: '+(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('base_ccy')).JsonValue.Value)+#13#10+
          Format('???? ???????:  %n', [(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('buy')).JsonValue.Value.ToSingle)])+' USD'+#13#10+
          Format('???? ???????:  %n', [(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('sale')).JsonValue.Value.ToSingle)])+' USD';
      end
      else
      begin
        MainListView.Items[i].Detail:='??? ??????: '+(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('ccy')).JsonValue.Value)+#13#10+
          '??? ???????????? ??????: '+(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('base_ccy')).JsonValue.Value)+#13#10+
          Format('???? ???????:  %n', [(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('buy')).JsonValue.Value.ToSingle)])+' UAH'+#13#10+
          Format('???? ???????:  %n', [(TJSONPair(TJSONObject(JSONMyArr.Get(i)).Get('sale')).JsonValue.Value.ToSingle)])+' UAH';
      end;

    MainListView.Items[i].Bitmap:=ImageList1.Source[0].Source.Items[0].MultiResBitmap[i].Bitmap;
    Application.ProcessMessages;
    Sleep(100);
  end;





end;

end.
