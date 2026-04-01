import * as ddb from '@aws-appsync/utils/dynamodb'
	
export function request(ctx) {
	return ddb.get({ 
	    key: { id: ctx.args.id },
	    projection: ['id', 'title', 'content', 'author']
	})
}

export const response = (ctx) => ctx.result