package lf.media.core.component.label
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class LfLabel extends Sprite
	{
		
		private const default_font_size:int = 12;
		private const default_font_color:String = "#FFFFFF";
		
		public function LfLabel()
		{
			super();
			
			this.mouseChildren = false;
			
			addChild(_tf);
			setWH(50,22);
		}
		
		
		
		public function setWH(w:int, h:int):void{
			_tf.width = w;
			_tf.height = h;
			
			hotArea();
		}
		
		public function set text(value:String):void{
			_label = value;
			setStyle(default_font_size,default_font_color);
		}
		
		
		public function get text():String{
			return _label;
		}
		
		
		
		public function setStyle(fontSize:int,color:String):void{
			var html:String = "<p align='center'><font size='"+fontSize +"'  color='"+color+"'"+"face='微软雅黑,Microsoft YaHei,Arial'>";
			html +=_label;
			html += "</font></p>";
			_tf.htmlText = html;
		}
		
		
		
		private function hotArea():void{
			this.graphics.clear();
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRect(0,0,_tf.width, _tf.height);
			this.graphics.endFill();
		}
		
		
		public function destroy():void{
			this.removeChild(_tf);
			_tf = null;
		}
		
		
		
		
		private var _tf:TextField = new TextField();
		private var _w:int = 50;
		private var _h:int = 22;
		private var _label:String = "";
		
		
	}
}