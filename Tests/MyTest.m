//
//  MyTest.m
//  MyTestable
//
//  Created by Gabriel Handford on 2/15/09.
//  Copyright 2009. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "SimpleCoreDataFactory.h"

@interface MyTest : GHTestCase {

}
- (void)clearEntity:(NSString *)entity;
- (void)insertDataForTest2:(NSString *)groupName AndTitle:(NSString *)title With:(SimpleCoreData *)simpleCoreData;
- (void)insertDataForTest3:(NSString *)groupName AndNumber:(NSInteger)number With:(SimpleCoreData *)simpleCoreData;
@end

@implementation MyTest

- (void)setUp 
{
	// Run before each test method
	SimpleCoreDataFactory *simpleCoreDataFactory = [SimpleCoreDataFactory sharedCoreData];
	simpleCoreDataFactory.xcdatamodelName = @"Test";
	simpleCoreDataFactory.sqliteName = @"Test";
}

- (void)tearDownClass
{
}

- (void)tearDown {
	// Run after each test method
	
	[self clearEntity:@"Test1"];
	[self clearEntity:@"Test2"];
	[self clearEntity:@"Test3"];
}

- (void)test01Count 
{
	NSDictionary *sort = [[[NSDictionary alloc] 
						  initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],nil] 
								  forKeys:[NSArray arrayWithObjects:@"timeStamp", nil]]
						  autorelease];

	SimpleCoreDataFactory *simpleCoreDataFactory = [SimpleCoreDataFactory sharedCoreData];
	NSFetchRequest *request = [simpleCoreDataFactory createRequest:@"Test1"];
	[simpleCoreDataFactory setSortDescriptors:request AndSort:sort];
	NSFetchedResultsController *fetchedResultsController = [simpleCoreDataFactory fetchedResultsController:request 
																					 AndSectionNameKeyPath:nil];
	
	SimpleCoreData *simpleCoreData = [simpleCoreDataFactory createSimpleCoreData:fetchedResultsController];
	
	
	// データはまだない
	NSInteger count1 = [simpleCoreData countObjects];
	GHAssertEquals(count1, 0, @"Test Count1");

	
	// テストデータを入力 (２データ）
	NSManagedObject *managedObject = [simpleCoreData newManagedObject];
	[managedObject setValue:[NSDate date] forKey:@"timeStamp"];
	[managedObject setValue:@"Test1" forKey:@"title"];
	[simpleCoreData saveContext];
	
	managedObject = [simpleCoreData newManagedObject];
	[managedObject setValue:[NSDate date] forKey:@"timeStamp"];
	[managedObject setValue:@"Test2" forKey:@"title"];
	[simpleCoreData saveContext];
	

	// ２つのデータが入っている
	NSInteger count2 = [simpleCoreData countObjects];
	GHAssertEquals(count2, 2, @"Test Count2");

	
	// fetchObjectでデータを取ってくる
	NSManagedObject *data1 = [simpleCoreData fetchObjectWithRow:0 
													  AndSection:0];
	GHAssertEqualStrings([data1 valueForKey:@"title"], @"Test2", @"Test 1st Data");
	

	NSManagedObject *data2 = [simpleCoreData fetchObjectWithRow:1
											   AndSection:0];
	GHAssertEqualStrings([data2 valueForKey:@"title"], @"Test1", @"Test 2nd Data");

	
	// fetchObjectDataでデータを取ってくる
	NSArray *datas = [simpleCoreData fetchObjectAll];
	NSInteger count3 = [datas count];
	GHAssertEquals(count3, 2, @"Test fetchAll");
	GHAssertEqualStrings([[datas objectAtIndex:0] valueForKey:@"title"], @"Test2", @"fetchAll 1st Data");
	GHAssertEqualStrings([[datas objectAtIndex:1] valueForKey:@"title"], @"Test1", @"fetchAll 2nd Data");
}

- (void)test02Predicate
{
	SimpleCoreDataFactory *simpleCoreDataFactory = [SimpleCoreDataFactory sharedCoreData];
	NSFetchRequest *request = [simpleCoreDataFactory createRequest:@"Test1"];
	
	NSDictionary *sort = [[[NSDictionary alloc]
						   initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil]
						   forKeys:[NSArray arrayWithObjects:@"timeStamp", nil]]
						  autorelease];
	[simpleCoreDataFactory setSortDescriptors:request AndSort:sort];
	
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", @"Test1"];
	[simpleCoreDataFactory setPredicate:request WithPredicate:predicate];
	
	
	NSFetchedResultsController *fetchedResultsController = [simpleCoreDataFactory fetchedResultsController:request
																					 AndSectionNameKeyPath:nil];
	
	
	SimpleCoreData *simpleCoreData = [simpleCoreDataFactory createSimpleCoreData:fetchedResultsController];
	
	
	// テストデータを入力 (２データ）
	NSManagedObject *managedObject = [simpleCoreData newManagedObject];
	[managedObject setValue:[NSDate date] forKey:@"timeStamp"];
	[managedObject setValue:@"Test1" forKey:@"title"];
	[simpleCoreData saveContext];
	
	managedObject = [simpleCoreData newManagedObject];
	[managedObject setValue:[NSDate date] forKey:@"timeStamp"];
	[managedObject setValue:@"Test2" forKey:@"title"];
	[simpleCoreData saveContext];
	
	NSInteger count = [simpleCoreData countObjects];
	GHAssertEquals(count, 1, @"Predicate Test Count");
	
	NSManagedObject *data = [simpleCoreData fetchObjectWithRow:0 AndSection:0];
	GHAssertEqualStrings([data valueForKey:@"title"], @"Test1", @"Predicate Test Data");
}

- (void)test03Grouping
{
	SimpleCoreDataFactory *simpleCoreDataFactory = [SimpleCoreDataFactory sharedCoreData];
	NSFetchRequest *request = [simpleCoreDataFactory createRequest:@"Test2"];
	
	NSDictionary *sort = [[[NSDictionary alloc]
						   initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil]
						   forKeys:[NSArray arrayWithObjects:@"timeStamp", nil]]
						  autorelease];
	[simpleCoreDataFactory setSortDescriptors:request AndSort:sort];
	
	NSFetchedResultsController *fetchedResultsController = [simpleCoreDataFactory fetchedResultsController:request
																					 AndSectionNameKeyPath:@"groupName"];
	
	SimpleCoreData *simpleCoreData = [simpleCoreDataFactory createSimpleCoreData:fetchedResultsController];
	
	[self insertDataForTest2:@"Group1" AndTitle:@"title1Group1" With:simpleCoreData];
	[self insertDataForTest2:@"Group1" AndTitle:@"title2Group1" With:simpleCoreData];
	[self insertDataForTest2:@"Group1" AndTitle:@"title3Group1" With:simpleCoreData];
	[self insertDataForTest2:@"Group2" AndTitle:@"title1Group2" With:simpleCoreData];
	[self insertDataForTest2:@"Group2" AndTitle:@"title2Group2" With:simpleCoreData];
	
	NSArray *sections = [simpleCoreData.fetchedResultsController sections];
	
	id <NSFetchedResultsSectionInfo> info1 = [sections objectAtIndex:0];
	NSInteger group1 = [info1 numberOfObjects];
	GHAssertEquals(group1, 3, @"Group1 numberOfObjects");
	
	id <NSFetchedResultsSectionInfo> info2 = [sections objectAtIndex:1];
	NSInteger group2 = [info2 numberOfObjects];
	GHAssertEquals(group2, 2, @"Group2 numberOfObjects");
}

- (void)test04Function
{
	SimpleCoreDataFactory *simpleCoreDataFactory = [SimpleCoreDataFactory sharedCoreData];
	NSFetchRequest *request = [simpleCoreDataFactory createRequest:@"Test3"];
	
	NSDictionary *sort = [[[NSDictionary alloc]
						   initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil]
						   forKeys:[NSArray arrayWithObjects:@"timeStamp", nil]]
						  autorelease];
	[simpleCoreDataFactory setSortDescriptors:request AndSort:sort];
	
	NSFetchedResultsController *fetchedResultsController = [simpleCoreDataFactory fetchedResultsController:request
																					 AndSectionNameKeyPath:@"groupName"];
	
	SimpleCoreData *simpleCoreData = [simpleCoreDataFactory createSimpleCoreData:fetchedResultsController];
	[self insertDataForTest3:@"Group1" AndNumber:10 With:simpleCoreData];
	[self insertDataForTest3:@"Group1" AndNumber:20 With:simpleCoreData];
	[self insertDataForTest3:@"Group1" AndNumber:30 With:simpleCoreData];
	[self insertDataForTest3:@"Group2" AndNumber:100 With:simpleCoreData];
	[self insertDataForTest3:@"Group2" AndNumber:200 With:simpleCoreData];
	

	/*
	 * Sum
	 */
	
	[simpleCoreDataFactory setFunction:fetchedResultsController.fetchRequest
							WithColumn:@"number" 
						   AndFunction:@"sum" 
							AndSetName:@"sumNumber"
						 AndResultType:NSInteger16AttributeType];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupName == %@", @"Group1"];
	[simpleCoreDataFactory setPredicate:simpleCoreData.fetchedResultsController.fetchRequest WithPredicate:predicate];
	
	NSArray *data1 = [simpleCoreData fetchObjectAll];
	NSInteger sum1 = [[[data1 objectAtIndex:0] valueForKey:@"sumNumber"] intValue];
	GHAssertEquals(sum1, 60, @"Sum 1");
	
	predicate = [NSPredicate predicateWithFormat:@"groupName == %@", @"Group2"];
	[simpleCoreDataFactory setPredicate:simpleCoreData.fetchedResultsController.fetchRequest WithPredicate:predicate];
	
	NSArray *data2 = [simpleCoreData fetchObjectAll];
	NSInteger sum2 = [[[data2 objectAtIndex:0] valueForKey:@"sumNumber"] intValue];
	GHAssertEquals(sum2, 300, @"Sum 2");
	
	
	/*
	 * Max
	 */
	
	[simpleCoreDataFactory setFunction:fetchedResultsController.fetchRequest
							WithColumn:@"number"
						   AndFunction:@"max"
							AndSetName:@"maxNumber"
						 AndResultType:NSInteger16AttributeType];
	
	predicate = [NSPredicate predicateWithFormat:@"groupName == %@", @"Group1"];
	[simpleCoreDataFactory setPredicate:simpleCoreData.fetchedResultsController.fetchRequest
						  WithPredicate:predicate];
	
	NSArray *data3 = [simpleCoreData fetchObjectAll];
	NSInteger max1 = [[[data3 objectAtIndex:0] valueForKey:@"maxNumber"] intValue];
	GHAssertEquals(max1, 30, @"Max 1");
	
	predicate = [NSPredicate predicateWithFormat:@"groupName == %@", @"Group2"];
	[simpleCoreDataFactory setPredicate:simpleCoreData.fetchedResultsController.fetchRequest
						  WithPredicate:predicate];
	
	NSArray *data4 = [simpleCoreData fetchObjectAll];
	NSInteger max2 = [[[data4 objectAtIndex:0] valueForKey:@"maxNumber"] intValue];
	GHAssertEquals(max2, 200, @"Max 2");
}



#pragma mark --- Support Method ---
#pragma mark ----------------------

- (void)insertDataForTest2:(NSString *)groupName AndTitle:(NSString *)title With:(SimpleCoreData *)simpleCoreData
{
	NSManagedObject *managedObject = [simpleCoreData newManagedObject];
	[managedObject setValue:[NSDate date] forKey:@"timeStamp"];
	[managedObject setValue:groupName forKey:@"groupName"];
	[managedObject setValue:title forKey:@"title"];
	[simpleCoreData saveContext];
}

- (void)insertDataForTest3:(NSString *)groupName AndNumber:(NSInteger )number With:(SimpleCoreData *)simpleCoreData
{
	NSManagedObject *managedObject = [simpleCoreData newManagedObject];
	[managedObject setValue:[NSDate date] forKey:@"timeStamp"];
	[managedObject setValue:groupName forKey:@"groupName"];
	[managedObject setValue:[NSNumber numberWithInt:number] forKey:@"number"];
	[simpleCoreData saveContext];
}

- (void)clearEntity:(NSString *)entity
{
	NSDictionary *sort = [[[NSDictionary alloc] 
						   initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],nil] 
						   forKeys:[NSArray arrayWithObjects:@"timeStamp", nil]]
						  autorelease];
	
	SimpleCoreDataFactory *simpleCoreDataFactory = [SimpleCoreDataFactory sharedCoreData];
	NSFetchRequest *request = [simpleCoreDataFactory createRequest:entity];
	[simpleCoreDataFactory setSortDescriptors:request AndSort:sort];
	NSFetchedResultsController *fetchedResultsController = [simpleCoreDataFactory fetchedResultsController:request 
																					 AndSectionNameKeyPath:nil];
	
	SimpleCoreData *simpleCoreData = [simpleCoreDataFactory createSimpleCoreData:fetchedResultsController];
	
	
	// 後処理
	NSArray *all = [simpleCoreData fetchObjectAll];
	NSInteger countFinal = [all count];
	for (int i = 0; i < countFinal; i++) {
		[simpleCoreData deleteObjectWithObject:[all objectAtIndex:i]];
	}
}


@end
