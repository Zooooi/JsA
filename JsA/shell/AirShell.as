package JsA.shell
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import JsC.shell.BaseShellSystem;
	import JsC.sys.SystemOS;
	
	import projectClass.vo.v.FilesVO;
	
	public class AirShell extends BaseShellSystem
	{
		
		override public function openFile(_url:String):void
		{
			var sFullPath:String = $dir( _url)
			var file:File = new File(sFullPath)
			file.openWithDefaultApplication()
		}
		
		override public function saveData(_data:String,_file:String,_path:String=""):void
		{
			var fileStream:FileStream = new FileStream();
			var sFullPath:String = _path + _file;
			fileStream.open(new File(sFullPath), FileMode.WRITE);
			fileStream.writeUTFBytes(_data);
			fileStream.close();
		}
		
		override public function saveText(_data:String,_file:String,_path:String=""):void
		{
			saveData(_data,_file,_path)
		}
		
		/**
		 * 
		 * 
		 */
		override public function setAppPath():void
		{
	
			
			
			trace("url: ",File.applicationStorageDirectory.url)
			trace("url: ",File.applicationDirectory .url)
			trace("url: ",File.desktopDirectory.url)
			trace("url: ",File.documentsDirectory.url)
			trace("url: ",File.userDirectory.url)
			trace("url: ------------------------------------------")
			trace("nativePath: ",File.applicationStorageDirectory.nativePath)
			trace("nativePath: ",File.applicationDirectory .nativePath)
			trace("nativePath: ",File.desktopDirectory.nativePath)
			trace("nativePath: ",File.documentsDirectory.nativePath)
			trace("nativePath: ",File.userDirectory.nativePath)
			trace("url: ------------------------------------------")
			trace("nativePath: ",File.applicationStorageDirectory.resolvePath("/").url)
			trace("nativePath: ",File.applicationDirectory.resolvePath("/").url)
			trace("nativePath: ",File.desktopDirectory.resolvePath("/").url)
			trace("nativePath: ",File.documentsDirectory.resolvePath("/").url)
			trace("nativePath: ",File.userDirectory.resolvePath("/").url)
			
			if (SystemOS.isPc)
			{
				FilesVO.setDocumentPath(File.documentsDirectory.url+"/")
				FilesVO.setAppPath(File.applicationDirectory.nativePath+"/")
			}else{
				FilesVO.setAppPath(File.applicationDirectory.nativePath+"/")
				if (SystemOS.isIOS()){
					FilesVO.setDocumentPath(File.documentsDirectory.url+"/")
				}else{
					FilesVO.setDocumentPath(File.applicationStorageDirectory.nativePath+"/")
				}
				 
			}
		}
		
		override public function createFolder(_folder:String):void
		{
			new File(_folder)
		}
		override public function browser():String
		{
			
			 /*var imageTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
			var docTypes:FileFilter = new FileFilter("Office (*.doc, *.xls, *.ppt)", "*.doc; *.xls; *.ppt;");
			var mp4Types:FileFilter = new FileFilter("Music (*.mp4)", "*.mp4");
			var allTypes:Array = new Array();
			allTypes.push(imageTypes)
			allTypes.push(docTypes)
			allTypes.push(mp4Types)
			var file:FileReference = new FileReference(); 
			file.addEventListener(Event.SELECT, onSelect);
			file.addEventListener(Event.COMPLETE, onSelected);
			file.browse(allTypes) */
			return "" ;
		}
		
		override public function deleteFile(_url:String):void
		{
			super.deleteFile(_url);
			var file:File = new File(_url)
			file.deleteFile()
			
		}
		
	
		
		
	}
}