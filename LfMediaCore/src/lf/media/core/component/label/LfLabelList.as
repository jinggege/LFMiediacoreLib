package lf.media.core.component.label
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Label;
	
	public class LfLabelList extends Sprite
	{
		
		public const E_LIST_SELECT:String = "E_LIST_SELECT";
		
		public function LfLabelList()
		{
			super();
			
			this.addEventListener(MouseEvent.CLICK,clickHandler);
		}
		
		public function setLabels(labels:Array):void{
			
				if(_labels != null){
					_labels = null;
				}
				
				if(_labelList.length>0){
					clearList();
				}
				
				_labels = labels;
		}
		
		
		public function setStyle(w:int,h:int,fontSize:int,nomalColor:String,selectColor:String,space:int=10):void{
			_fontSize = fontSize;
			_selectColor  = selectColor;
			_nomalColor = nomalColor;
			var item:LfLabel;
			for(var i:int = 0; i<_labels.length; i++){
				item = new LfLabel();
				item.text = _labels[i];
				item.setWH(w,h);
				item.setStyle(fontSize,nomalColor);
				addChild(item);
				_labelList.push(item);
				item.y = i*(item.height +space)
				item.buttonMode = true;
			}
		}
		
		
		
		private function clickHandler(event:MouseEvent):void{
			var item:LfLabel = event.target as LfLabel;
			if(item == null) return;
			
			_currLabel = item.text;
			
			selected(_currLabel);
			
			this.dispatchEvent(new Event(E_LIST_SELECT));
		}
		
		
		public function selected(text:String):void{
			for(var i:int=0; i<_labelList.length; i++){
				_labelList[i].setStyle(_fontSize,_nomalColor);
				if(_labelList[i].text == text){
					_labelList[i].setStyle(_fontSize,_selectColor);
				}
			}
		}
		
		
		
		public function get currentLabel():String{
			return _currLabel;
		}
		
		
		public function get list():Vector.<LfLabel>{
			return _labelList;
		}
		
		
		
		public function clearList():void{
			
			for(var i:int=0; i<_labelList.length; i++){
				_labelList[i].destroy();
				removeChild(_labelList[i]);
				_labelList[i] = null;
				_labelList.splice(i,1);
			}
		}
		
		
		
		
		private var _labelList:Vector.<LfLabel> = new Vector.<LfLabel>();
		private var _labels:Array;
		private var _selectColor:String = "#c9ff13";
		private var _nomalColor:String = "#FFFFFF";
		private var _fontSize:int = 12;
		private var _currLabel:String = "";
		
		
		
		
	}
}