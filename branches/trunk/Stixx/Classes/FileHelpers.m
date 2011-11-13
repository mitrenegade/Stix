/*
 *  FileHelpers.m
 *  ARKitDemo
 *
 *  Created by Administrator on 6/1/11.
 *  Copyright 2011 Neroh. All rights reserved.
 *
 */

#include "FileHelpers.h"

NSString *pathInDocumentDirectory(NSString *fileName)
{	
	// constructs full path in Documents directory for saving and loading application data
	
	// Get list of document directories in sandbox 
	NSArray *documentDirectories =
		NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	// Get one and only document directory from that list 
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	// Append passed in file name to that directory, return it 
	return [documentDirectory stringByAppendingPathComponent:fileName];
}